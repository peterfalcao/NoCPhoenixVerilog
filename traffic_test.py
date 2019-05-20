import subprocess
import sys
import glob
import os
import time

path= "./obj_dir/VNOC"

def test_loop(progs):
	failed = 0
	failure = subprocess.call(progs)
	return failed

def main():
	folders = glob.glob('./tests/*')
	progs = []
	
	for folder in folders:
		progs.append(path)
		files=glob.glob(folder+'/In/*.txt')
		print(files)
		for file in files:
			progs.append(file)
		print('+++++++++++++testando trafego: '+folder+" ++++++++++++++++++++++++")
		inicio = time.time()
		test_loop(progs)
		aux=[]
		progs=aux
		fim = time.time()
		print('Tempo de execução do trafego '+folder+" : "+str(fim - inicio))
main();
