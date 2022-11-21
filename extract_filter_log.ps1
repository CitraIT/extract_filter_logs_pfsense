# Citra IT - Excelencia em TI
# Script para extrair IPs do log de firewall do pfSense
# @Version: 1.0
# @Date: 21/11/2022
# @Author: luciano@citrait.com.br
# @Description: Este script le da linha de comandos o caminho do arquivo filter.log
#   e extrai os ips que foram bloqueados.
# @Usage: powershell .\extract_filter_log.ps1 C:\logs\filter.log.0
#  ao final da execução, será gerado o arquivo ips.txt na mesma pasta deste script.

Write-Host "Starting script of ip extraction..."
# Lendo o caminho do arquivo de log (filter.log) como argumento da linha de comando
$input_file = $args[0]

# Arquivo onde salvar a lista de ips extraídos do log de firewall do pfsense.
$output_file = "ips.txt"
Write-Host "Output list of extracted ip addresses will be on file $output_file"

# Remover o arquivo de saida se existir para criar um novo
Write-Host "Removing older $output_file"
Remove-Item $output_file -Force -Confirm:$false -EA SilentlyContinue

# do the magic \0/
Write-Host "Extracting addresses..."
Get-Content $input_file | Where-Object{
	# Separar (split) os campos de cada entrada de log
	$fields = $_.Split(",");
	
	# filtra por direction (in), action (blocked), IPVersion (ipv4), proto (tcp), e source addr que não é de uma rede privada.
	if($fields[7] -eq "in" `
		-and $fields[6] -eq "block" `
		-and $fields[8] -eq "4" `
		-and $fields[16] -eq "tcp" `
		-and $fields[18] -notmatch '(^192\.168|^10|^172)'){
			return $true
	}Else{ 
		return $false 
	}
} | Select-Object @{"Name"="Source"; Expression={$_.Split(",")[18]}} | `
	Select-Object -ExpandProperty Source | Add-Content $output_file
