import subprocess
import sys
import glob
import os
import time

path= "./obj_dir/VNOC"

def test_loop(progs):
	failed = 0
	failed = subprocess.call(progs)
	return failed

def main():
	folders = glob.glob('./tests/F001')
	progs = []
	fails=0;
	for folder in folders:
		progs.append(path)
		files=glob.glob(folder+'/In/*.txt')
		print(files)
		for file in files:
			progs.append(file)
		print('+++++++++++++testando trafego: '+folder+" ++++++++++++++++++++++++")
		inicio = time.time()
		fails=fails+test_loop(progs)
		print('+++++++++++++fails= '+str(fails)+" ++++++++++++++++++++++++")
		aux=[]
		progs=aux
		fim = time.time()
		print('Tempo de execução do trafego '+folder+" : "+str(fim - inicio))
	if(fails>0):
		print(str(fails)+' falha(s) detectadas')
	else:
		print('Todos os testes foram concluídos com sucesso')
main();
