"""Unit tests for the removal list in check_conversion.py (no Dymola needed).

Run: python3 -m unittest scripts/test_check_conversion.py
"""
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import check_conversion as cc  # noqa: E402

REPORT = """<html><body><p>Conversion report</p><table>
<tr><th>Message</th><th>Class</th><th></th><th></th></tr>
<tr><td>Old class is missing, without conversion</td><td>TRANSFORM.Obsolete.Math.Interpolation.Bicubic</td><td></td><td></td></tr>
<tr><td>Conversion missing in a model extending . Conversion necessary for both base model and extended model.</td><td>TRANSFORM.Obsolete.Media</td><td></td><td></td></tr>
</table></body></html>"""


class RemovalList(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp, True)
        self.conv = self.tmp / "TRANSFORM" / "Resources" / "Scripts" / "Conversion"
        self.conv.mkdir(parents=True)
        self.report = self.tmp / "report.html"
        self.report.write_text(REPORT, encoding="utf-8")

    def write(self, version, text):
        (self.conv / ("Removed_%s.txt" % version)).write_text(text, encoding="utf-8")

    def test_listed_removals_pass(self):
        self.write("1.4.0", "# comment\nTRANSFORM.Obsolete.Math\nTRANSFORM.Obsolete.Media  # trailing\n")
        removed, files = cc.load_removed(self.tmp, "1.3.0")
        self.assertEqual(removed, ["TRANSFORM.Obsolete.Math", "TRANSFORM.Obsolete.Media"])
        self.assertEqual(cc.unexplained(cc.table_rows(self.report), removed), [])

    def test_unlisted_class_fails(self):
        self.write("1.4.0", "TRANSFORM.Obsolete.Math\n")
        removed, _ = cc.load_removed(self.tmp, "1.3.0")
        left = cc.unexplained(cc.table_rows(self.report), removed)
        self.assertEqual([r[1] for r in left], ["TRANSFORM.Obsolete.Media"])

    def test_prefix_needs_a_dot_boundary(self):
        # LookupTableMedia must not cover LookupTableMedianew.
        rows = [["Old class is missing, without conversion", "TRANSFORM.Media.LookupTableMedianew.X"]]
        self.assertEqual(len(cc.unexplained(rows, ["TRANSFORM.Media.LookupTableMedia"])), 1)

    def test_other_messages_never_pass(self):
        rows = [["New class missing", "TRANSFORM.Obsolete.Math.X"]]
        self.assertEqual(len(cc.unexplained(rows, ["TRANSFORM.Obsolete.Math"])), 1)

    def test_lists_for_the_tag_or_older_are_ignored(self):
        self.write("1.3.0", "TRANSFORM.Obsolete.Math\n")
        removed, files = cc.load_removed(self.tmp, "1.3.0")
        self.assertEqual((removed, files), ([], []))

    def test_lists_newer_than_the_library_are_ignored(self):
        self.write("1.9.0", "TRANSFORM.Obsolete.Math\n")
        self.assertEqual(cc.load_removed(self.tmp, "1.3.0", "1.4.0-dev"), ([], []))
        self.assertEqual(cc.load_removed(self.tmp, "1.3.0", "1.9.0")[0], ["TRANSFORM.Obsolete.Math"])

    def test_a_listed_class_that_still_exists_is_reported(self):
        (self.tmp / "TRANSFORM" / "Media").mkdir(parents=True)
        (self.tmp / "TRANSFORM" / "Media" / "package.mo").write_text("", encoding="utf-8")
        (self.tmp / "TRANSFORM" / "Math").mkdir(parents=True)
        (self.tmp / "TRANSFORM" / "Math" / "besselY.mo").write_text("", encoding="utf-8")
        found = cc.still_present(self.tmp, ["TRANSFORM.Media", "TRANSFORM.Math.besselY",
                                            "TRANSFORM.Media.LookupTableMedia"])
        self.assertEqual(found, ["TRANSFORM.Media", "TRANSFORM.Math.besselY"])

    def test_version_key(self):
        self.assertEqual(cc.version_key("1.4.0-dev"), (1, 4, 0))
        self.assertGreater(cc.version_key("1.10.0"), cc.version_key("1.9.0"))
        self.assertEqual(cc.version_key("1.0"), (1, 0, 0))


if __name__ == "__main__":
    unittest.main()
