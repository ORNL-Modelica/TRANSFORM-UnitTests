from pymodelica import compile_fmu
from pyfmi import load_fmu

libPath = r'C:\Users\fig\Documents\Modelica\TRANSFORM-Library/TRANSFORM'
modelName = 'TRANSFORM.Units.Conversions.Functions.Time_s.Examples.check_yr'

fmu = compile_fmu(modelName,libPath,target='cs')
model = load_fmu(fmu)

opts = model.simulate_options()
opts['time_limit'] = 60

results=model.simulate(options=opts)
