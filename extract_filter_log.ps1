# Citra IT - Excelencia em TI
# Script para extrair IPs do log de firewall do pfSense
# @Version: 1.0
# @Date: 21/11/2022
# @Author: luciano@citrait.com.br
# @Description: Este script le da linha de comandos o caminho do arquivo filter.log
#   e extrai os ips das regras que bloquearam na interface wan (em0) pacotes ipv4
#   que não foram solicitados.
# @Usage: powershell .\extract_filter_log.ps1 C:\logs\filter.log.0
#  ao final da execução, será gerado o arquivo ips.txt na mesma pasta.

$input_file = $args[0]
$output_file = "ips.txt"

# Remover o arquivo de saida se existir;

Remove-Item $output_file -Force -Confirm:$false -EA SilentlyContinue

Get-Content $input_file | Where-Object{
	$fields = $_.Split(",");
	if($fields[7] -eq "in" `
		-and $fields[4] -eq "em0" `
		-and $fields[6] -eq "block" `
		-and $fields[8] -eq "4" `
		-and $fields[16] -eq "tcp"){
			return $true
	}Else{ 
		return $false 
	}
} | Select-Object @{"Name"="Source"; Expression={$_.Split(",")[18]}} | `
	Select-Object -ExpandProperty Source | Add-Content $output_file


	
	
	
