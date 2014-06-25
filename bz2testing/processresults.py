#!/usr/bin/python3
import os
import re
import numpy
from scipy import stats
import glob
import sys

#files = os.listdir('testresults');
#files = glob.glob(sys.argv[1]);
#we are on linux so the shell does globbing for us

#print(files)

# list of tuples
# first entry in each tuple is the filename, second entry is the data.
datasets = []

sys.stderr.write('begin reading files\n');

#for f in files:
#print(len(sys.argv))
for x in range(1,len(sys.argv)):
	#print(x);
	f = sys.argv[x]
	if os.path.isfile(f):
		#print(f)
		with open(f, 'r') as content_file:
			contents = content_file.read()
		pattern = re.compile('[0-9.]+(?=user)')
		matches = pattern.findall(contents)
		#print(matches)
		values = [float(i) for i in matches]
		datasets.append((f,values))
#print(datasets)

sys.stderr.write('end reading files\n');


#note: minimum safe value for n  seems to be 6, lower values 
#can cause output failure
#debug levels
#0: no output on stderr
#1: output on stderr on failure only
#2: full debug output on stderr
def ncharnumber(num,n,debuglevel):
	p = n-1;
	toolong = True;
	while toolong and (p > 0):
		s = ('{:.'+str(p)+'G}').format(num)
		if debuglevel == 2: 
			sys.stderr.write(str(num)+' '+str(p)+' '+s+'\n');
		toolong = (len(s) > n)
		#print(str(p)+' '+str(len(s)))
		p -= 1;
	if p < 0:
		if debuglevel == 1:
			ncharnumber(num,n,2)
		elif debuglevel == 2:
			sys.stderr.write(str(num)+' error\n');
		return 'error'
	else: 
		return s;

#print(ncharnumber(5.123456789,5))
#sys.exit();

sys.stderr.write('begin finding prefix and suffix of filenames\n');


#check for common prefix
match = True
i=-1
while match:
	i += 1
	cm = '!!'
	for item in datasets:
		s = item[0];
		c = s[i]
		if cm == '!!':
			cm = c
		else:
			if cm != c:
				match = False
				break


commonprefixlen = i;
commonprefix = datasets[0][0][0:commonprefixlen]
#print(commonprefix);

#check for common suffix
match = True
i=-1
while match:
	i += 1
	cm = '!!'
	for item in datasets:
		s = item[0];
		c = s[-i-1]
		if cm == '!!':
			cm = c
		else:
			if cm != c:
				match = False
				break


commonsuffixlen = i;
commonsuffix = datasets[0][0][-commonsuffixlen:]
#print(commonsuffix);

#distinctpart = datasets[0][0][commonprefixlen:-commonsuffixlen]
#print(distinctpart);

def distinctnamepart(name):
	return name[commonprefixlen:-commonsuffixlen]

#sys.exit();

sys.stderr.write('begin output generation\n');

print('<html>')
print('<body>')

print('<table border=1>')
print('<tr><th>name</th><th>mean</th><th>stdev</th></tr>');

for row in datasets:
	print
	print('<tr>', end="")
	mean = numpy.mean(row[1])
	stddev = numpy.std(row[1],ddof=1)
	print('<td>'+row[0]+'</td>', end="")
	print('<td>'+ncharnumber(mean,6,1)+'</td>', end="")
	print('<td>'+ncharnumber(stddev,6,1)+'</td>', end="")
	print('</tr>')


print('</table>');

print('<table border=1>')

print('<tr><th></th>', end="")
for column in datasets:
	print('<th colspan=4>'+distinctnamepart(column[0])+'</th>',end="")
print('</tr>')

print('<tr><th></th>', end="")
for column in datasets:
	print('<th>&Delta;&mu;</th><th>&Delta;&mu;%</th><th>t</th><th>p</th>',end="")
print('</tr>')


for row in datasets:
	print('<tr><th>'+distinctnamepart(row[0])+'</th>', end="")
	for column in datasets:
		meancol = numpy.mean(column[1])
		meanrow = numpy.mean(row[1])
		meandiff = meancol-meanrow
		t,p = stats.ttest_ind(row[1],column[1])
		print('<td>'+ncharnumber(meandiff,6,1)+'</td>', end="")
		print('<td>'+ncharnumber(meandiff/meanrow*100,6,1)+'</td>', end="")
		print('<td>'+ncharnumber(t,6,1)+'</td>', end="")
		print('<td>'+ncharnumber(p,6,1)+'</td>', end="")
	print('</tr>')

print('</table>');

#		print()#
#		print(row[0]);#
#		print(row[1]);
#		print(column[0]);
#		print(column[1]);
#		print(stats.ttest_ind(row[1],column[1]));


#		print(values)
#		mean = numpy.mean(values)
#		std = numpy.std(values,ddof=1)
#		print(str(mean)+' '+str(std))
