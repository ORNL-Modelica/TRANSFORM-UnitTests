# TRANSFORM-UnitTests

This repository holds the reference or "gold" result files for regression tests for the Modelica Library TRANSFORM (TRANSFORM-Library/TRANSFORM).

In the past this was included in the TRANSFORM-Library Resources folder but now resided here to reduce library bloat and avoid file path lenth issues.

# Instructions

1. Create unit scripts
    - These are stored in the repository for change purposes but can be regenerated at will.
    - To regenerate the unit tests included in TRANSFORM run: `createUnitScripts.py`
    - This will create a folder called `Scripts` and place them there. These files are used for regression testing.
    - This will also create a `runAll*.mo` file which can be run directly in the Modelica IDE, independent of the regression system. This will be placed in the library path.
1. Run regression tests
    - This is based off of the buildingspy regression system for now.
    - After installing buildingspy (pip install buildingspy):
        1. Navigate to buildinspy.development.regressiontest
            - On line ~956 modify as follows:
                ```
                if len(tols) == 0:
                    tols = ['1e-4']
                    # raise RuntimeError("Failed to find Tolerance in '{}'.".format(file_name))
                ```
                - Reason: Changes to buildingspy now require tolerance to be included but it is not included by default from Dymola. A fix to avoid modifying this file be to go and modify all .mo files.
            - On line ~1177 comment out:
                ```
                # if len(dat['ScriptFile']) >= 131:
                #     self._reporter.writeError(
                #         """File {} is {}-character long. Reduce it to maximum of 130 characters.""".format(
                #             dat['ScriptFile'], len(
                #                 dat['ScriptFile'])))
                ```
                - Reason: The naming scheme uses the whole path to the test. This creates long names which can cause issues in Windows. Good practice may be to limit nesting in the Modelica library. Better would be to move that to a library check function separate from this and do result file names differently.
        1. Add your Modelica IDE to the system path
            - e.g., Add `C:\Program Files\Dymola 2024x Refresh 1\bin64` to the `Path` system variable.
        1. Run `runRegressionTests.py` to run the tests with regression checking.
            - This will copy the reference results and scripts that are located in this repository to the location of the library specified.
            - 

# Future work
Someday it would be good to revisit the regression test system approach to be more straightforward and robust. Ideas include: 
- Switch to an ID based approach for test naming to avoid path length issues
- Improve the reference results structure (if possible)
- Simplify/improve the results vs tests comparsion and file updating process.
- Ensure process is generalized to any library
- Enable pip install or other method to simplify adoption/usage
- Make more awesome plots
- Enable use in continuous integration system 
- Improve in-progress testing reporting and post result summary
