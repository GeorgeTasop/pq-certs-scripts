import sys
inFile = str(sys.argv[1])

if '.crt' in inFile:
    outFile = inFile.replace('.crt', '.txt')
if '.der' in inFile:
    outFile = inFile.replace('.der', '.txt')
if '.key' in inFile:
    outFile = inFile.replace('.key', '.txt')
    
with open(inFile, "rb") as f:
    buff = f.read()
chList = ['{:02X}'.format(b) for b in buff]
out = ''
count = 1
for each in chList:
    out += '0x'+each+', '
    if (count%10==0):
    	out += '\n'
    count = count + 1
out = out[:-2]
with open(outFile, 'w') as f:
    f.write(out)
