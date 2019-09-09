#!/usr/bin/python3
# This file is part of MOLGW
# Author: Fabien Bruneval
#
# This script creates several files (in FORTRAN and html formats) that contain the input variables of MOLGW. 
#
# The names of variables, their default values, etc. are read from the input_variables.yaml file.
# If you want to add a new variable, open the input_variables.yaml file and add a variable according to the yaml data format.
#

import time,os,sys

from yaml        import load,dump
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

today=time.strftime("%d")+' '+time.strftime("%B")+' '+time.strftime("%Y")

def printhtml(output,key,value):
  output.write('<hr>\n')
  output.write('<a name='+key+'>')
  output.write('<li>      \
           <span style="display:inline-block;background:#EEEEEE;width:400px">    \
           <b>'+key+'</b>  </span>  \n')

  if value['experimental'] == 'yes':
    output.write('<b><font color="red">EXPERIMENTAL</font> </b> \n')
  output.write('<br><br>\n')

  if value['mandatory'] == 'yes':
    output.write('<i>Mandatory</i><br>\n')
  else:
    output.write('<i>Optional</i><br>\n')
  if value['default'] == '':
    output.write('Default: None<br><br>\n')
  else:
    output.write('Default: '+str(value['default'])+'<br><br>\n')
  output.write(value['comment']+'</li><br>\n')



with open('input_variables.yaml', 'r') as stream:
    input_var_dict = load(stream,Loader=Loader)

#============================================================================
#            Fortran output: input variable declaration
#============================================================================

script_file_name = os.path.basename(__file__)
header = '!======================================================================\n'            + \
         '! The following lines have been generated by a python script: '+script_file_name+'\n' + \
         '! Do not alter them directly: they will be overriden sooner or later by the script\n' + \
         '! To add a new input variable, modify the script directly\n'                          + \
         '! Generated by '+script_file_name+' on '+today+'\n'                                   + \
         '!======================================================================\n\n'

print("Set up file: ../src/input_variable_declaration.f90")
ffor = open('../src/input_variable_declaration.f90','w')

ffor.write(header)

for key,value in input_var_dict.items():
  # Exclude a few input variable due to name clash
  if key in ['basis','auxil_basis','natom','nghost','read_restart']:
    continue

  if   value['datatype'] =='integer':
    ffor.write(' integer,protected :: ' + key +'\n')
  elif value['datatype'] =='real':
    ffor.write(' real(dp),protected :: ' + key +'\n')
  elif value['datatype'] =='vector_1d_3':
    ffor.write(' real(dp),protected :: ' + key +'(3)\n')
  elif value['datatype'] =='yes/no':
    ffor.write(' character(len=3),protected :: ' + key +'\n')
  elif value['datatype'] =='characters':
    ffor.write(' character(len=140),protected :: ' + key +'\n')
  else:
    sys.exit('Datatype of variable '+str(key)+' ('+str(value['datatype'])+') is not known')
    
ffor.write('\n\n!======================================================================\n')
ffor.close()

#============================================================================
#            Fortran output: input variable declaration, input variable namelist, and their default value
#============================================================================

print("Set up file: ../src/input_variables.f90")
ffor = open('../src/input_variables.f90','w')

ffor.write(header)

ffor.write(' namelist /molgw/   &\n')
for i,key in enumerate(input_var_dict.keys()):
  if i < len(input_var_dict.keys())-1:
    ffor.write('    '+key+',       &\n')
  else: # last element 
    ffor.write('    '+key+'\n'*2)

ffor.write('!=====\n\n')

for key,value in input_var_dict.items():
  if   value['datatype'] =='integer':
    ffor.write(' '+key+'='+str(value['default'])+'\n')
  elif value['datatype'] =='real':
    ffor.write(' '+key+'='+str(value['default'])+'_dp \n')
  elif value['datatype'] =='vector_1d_3':
     x,y,z=str(value['default']).strip("()").split(',')
     ffor.write(' '+key+'='+'(/ '+x+'_dp ,'+y+'_dp ,'+z+'_dp'+' /)'+'\n')
  elif value['datatype'] =='yes/no' or value['datatype'] =='characters':
    ffor.write(' '+key+'=\''+str(value['default'])+'\'\n')
  else:
    sys.exit('Datatype of variable '+str(key)+' ('+str(value['datatype'])+') is not known')

ffor.write('\n\n!======================================================================\n')
ffor.close()

#============================================================================
#            Fortran output: Echoing of all the input variable values
#============================================================================


print("Set up file: ../src/echo_input_variables.f90")
ffor = open('../src/echo_input_variables.f90','w')

ffor.write(header)

for key,value in input_var_dict.items():
  if   value['datatype'] =='integer':
    fortran_format = '\'(1x,a24,2x,i8)\''
  elif value['datatype'] =='real':
    fortran_format = '\'(1x,a24,2x,es16.8)\''
  elif value['datatype'] =='vector_1d_3':
    fortran_format = '\'(1x,a24,2x,"(",3(es16.8,2x),")")\''
  elif value['datatype'] =='yes/no':
    fortran_format = '\'(1x,a24,6x,a)\''
  elif value['datatype'] =='characters':
    fortran_format = '\'(1x,a24,6x,a)\''
  else:
    sys.exit('Datatype of variable '+str(key)+' ('+str(value['datatype'])+') is not known')
  ffor.write(' write(stdout,'+fortran_format+') \''+key+'\','+key+' \n')
    
ffor.write('\n\n!======================================================================\n')
ffor.close()

#============================================================================
#            Fortran output: Echoing of all the input variable values in YAML format
#============================================================================

print("Set up file: ../src/echo_input_variables_yaml.f90")
ffor = open('../src/echo_input_variables_yaml.f90','w')

ffor.write(header)

for key,value in input_var_dict.items():
  key_modif = key
  right_spaces = str( 30 - len(key) )

  if 'real' in value['datatype']:
    fortran_format = '\'(4x,a,' + right_spaces + 'x,es16.8)\''

  elif 'integer' in value['datatype']:
    fortran_format = '\'(4x,a,' + right_spaces + 'x,i8)\''

  elif 'characters' in value['datatype']:
    key_modif = 'TRIM(' + key_modif + ')'
    fortran_format = '\'(4x,a,' + right_spaces + 'x,a)\''

  elif 'yes' in value['datatype']:
    if 'y' in key.lower():
        key_modif = "'"+str(True)+"'"
    else:
        key_modif = "'"+str(False)+"'"
    fortran_format = '\'(4x,a,' + right_spaces + 'x,a)\''

  elif 'vector_1d_3' in value['datatype']:
    fortran_format = '\'(4x,a,' + right_spaces + 'x,"[",es16.8,", ",es16.8,", ",es16.8,"]")\''

  else:
    sys.exit('Datatype of variable '+str(key)+' ('+str(value['datatype'])+') is not known')

  ffor.write(' write(unit_yaml,'+fortran_format+') \''+key+':\','+key_modif+' \n')

ffor.write('\n\n!======================================================================\n')
ffor.close()


#============================================================================
#            HTML output
#============================================================================
print("Set up file: ../docs/input_variables.html")
fhtml = open('../docs/input_variables.html','w')

fhtml.write('<html>\n')
fhtml.write('<head>\n')
fhtml.write('<link rel="stylesheet" type="text/css" href="molgw.css">\n')
fhtml.write('</head>\n')

fhtml.write('<body>\n')
fhtml.write('<a name=top>\n')
fhtml.write('<h1>Input variable list</h1>\n')
fhtml.write('<hr>\n<br>\n')

# Mandatory
fhtml.write('<h3>Mandatory input variables</h3>\n<p>\n')
for key,value in input_var_dict.items():
  if value['mandatory'] == 'yes':
    fhtml.write('<a href=#'+key+'>'+key+'</a> ')

# System
fhtml.write('<h3>Physical system setup input variables</h3>\n<p>\n')
for key,value in input_var_dict.items():
  if value['family'] =='system':
    fhtml.write('<a href=#'+key+'>'+key+'</a> ')

# General
fhtml.write('<h3>General input variables</h3>\n<p>\n')
for key,value in input_var_dict.items():
  if value['family'] =='general':
    fhtml.write('<a href=#'+key+'>'+key+'</a> ')

# SCF
fhtml.write('<h3>Self-consistency input variables</h3>\n<p>\n')
for key,value in input_var_dict.items():
  if value['family'] =='scf':
    fhtml.write('<a href=#'+key+'>'+key+'</a> ')

# Post 
fhtml.write('<h3>Correlation and excited states post-treatment input variables</h3>\n<p>\n')
for key,value in input_var_dict.items():
  if value['family'] =='post':
    fhtml.write('<a href=#'+key+'>'+key+'</a> ')

# IO family
fhtml.write('<h3>IO input variables</h3>\n<p>\n')
for key,value in input_var_dict.items():
  if value['family'] =='io':
    fhtml.write('<a href=#'+key+'>'+key+'</a> ')

# Parallelization family
fhtml.write('<h3>Hardware input variables</h3>\n<p>\n')
for key,value in input_var_dict.items():
  if value['family'] =='hardware':
    fhtml.write('<a href=#'+key+'>'+key+'</a> ')

# Real-time TDDFT
fhtml.write('<h3>Real time TDDFT</h3>\n<p>\n')
for key,value in input_var_dict.items():
  if value['family'] =='rt_tddft':
    fhtml.write('<a href=#'+key+'>'+key+'</a> ')

# IO Real-time TDDFT
fhtml.write('<h3>IO Real time TDDFT</h3>\n<p>\n')
for key,value in input_var_dict.items():
  if value['family'] =='io_rt_tddft':
    fhtml.write('<a href=#'+key+'>'+key+'</a> ')



fhtml.write('<br><br><br><hr>\n')

# Start the complete list
fhtml.write('<br><br><br>\n')
fhtml.write('<h2>Complete list of input variables</h2>\n')
fhtml.write('<br><br>\n<ul>\n')
for key,value in input_var_dict.items():
  printhtml(fhtml,key,value)
fhtml.write('</ul>\n')
fhtml.write('<br><br><br><br><br><br><br><br>\n')
fhtml.write('<a href=#top>Back to the top of the page</a> ')
fhtml.write('<div style="float: right"><a href=molgw_manual.html>Back to the manual</a></div>')
fhtml.write('<br><br>')
fhtml.write('<i>Generated by '+script_file_name+' on '+today+'</i>')
fhtml.write('<br><br>')
fhtml.write('</body>\n')
fhtml.write('</html>\n')

fhtml.close()

print("Done!")


