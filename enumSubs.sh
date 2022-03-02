#!/bin/bash

url=$1

echo
if [ $# -eq 0 ] || [ $1 = '-h' ];
then
	echo "Modo de usar: ./enumSubs \$DOMÍNIO"
	echo "OBS: Para o script funcionar, você precisa das seguintes ferramentas instaladas:
	- assetFinder
	- findomain-linux
	- subfinder
	- amass
	- anew
	- httpx"
	
else

	echo
	echo "Você deseja que a ferramente AMASS seja usada na pesquisa? [s/N]"
	echo "Isso faz com que o resultado seja mais demorado, mas podem ser encontrados mais subdomínios!"
	read amass

	# Criando diretório subdomains
	if [ ! -d "subdomains" ]; 
	then
		mkdir subdomains
		echo "[ + ] Diretório "subdomains" criado"
	fi

	cd subdomains

	echo "[ + ] Rodando as Ferramentas de Enumeração de Subdomínios no Alvo: $url"
	echo
	echo "-----------------------------------------------------------------------------------------------------"

	# Rodando assetFinder
	assetfinder -subs-only $url | anew -q assetFinder.txt 
	assetFinder_result=$(wc -l assetFinder.txt | awk '{print $1;}')
	echo "$assetFinder_result subdomínios encontrados pelo assetFinder"

	# Rodando findomain
	findomain-linux -q -t $url | anew -q findomain.txt
	findomain_result=$(wc -l findomain.txt | awk '{print $1;}')
	echo "$findomain_result subdomínios encontrados pelo findomain"

	# Rodando subfinder
	subfinder -silent -d $url | anew -q subfinder.txt 
	subfinder_result=$(wc -l subfinder.txt | awk '{print $1;}')
	echo "$subfinder_result subdomínios encontrados pelo subfinder"

	# Rodando amass
	if [ "${amass^^}" == "S" ];	
	then
		echo "[ + ] Fazendo a consulta pelo AMASS"
		amass enum -d $url | anew -q amass.txt 
		amass_result=$(wc -l amass.txt | awk '{print $1;}')
		echo $amass_result subdomínios encontrados pelo amass
	fi
	echo "-----------------------------------------------------------------------------------------------------"
	echo
	
	cat * | anew -q all-subdomains.txt
	rm -rf working-subdomains.txt
	cat all-subdomains.txt | httpx -silent | anew -q working-subdomains.txt #Testando os subdomínios
	echo "Ao todo foram encontrados $(wc -l all-subdomains.txt | awk '{print $1;}') subdomínios, sendo $(wc -l working-subdomains.txt | awk '{print $1;}') acessíveis!"
	
fi
