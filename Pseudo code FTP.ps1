# Configuration des param�tres
$ftpHost = "172.26.25.195" # Remplacez par l'adresse de votre serveur FTP
Write-Host "entrer le chemin de votre archive"
$ftpFilePath = Read-Host # Chemin de l'archive sur le serveur FTP
Write-Host "entrer le chemin du point de sauvegarde"
$localPath = Read-Host # Chemin local pour sauvegarder l'archive
$ftpUsername = "admine" # Utilisateur FTP
$ftpPassword = "123456" # Mot de passe FTP

# Param�tres pour l'envoi des emails
$smtpServer = "smtp.gmail.com" # Serveur SMTP
$smtpPort = 587 # Port SMTP (souvent 587 ou 465 pour SSL/TLS)
Write-Host "entrer votre adresse email"
$smtpUsername = Read-Host  # Email exp�diteur
Write-Host "entrer votre mot de passe"
$smtpPassword = Read-Host # Mot de passe du compte email
Write-Host "entrer l'adresse de l'administrateur"
$emailRecipient = Read-Host "entrer l'adresse de l'administrateur" # Destinataire

# Fonction pour envoyer un email
function Envoyer-Email {
    param (
        [string]$sujet,
        [string]$corps
    )

    try {
        Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -Credential (New-Object System.Management.Automation.PSCredential($smtpUsername, (ConvertTo-SecureString $smtpPassword -AsPlainText -Force))) `
                          -From $smtpUsername -To $emailRecipient -Subject $sujet -Body $corps -UseSsl -ErrorAction Stop
    } catch {
        Write-Error "Erreur lors de l'envoi de l'email : $_"
    }
}

# T�l�chargement de l'archive
try {
    # Cr�ation de la requ�te Web pour le t�l�chargement
    $webClient = New-Object System.Net.WebClient
    $webClient.Credentials = New-Object System.Net.NetworkCredential($ftpUsername, $ftpPassword)

    Write-Host "T�l�chargement de l'archive depuis $ftpHost$ftpFilePath vers $localPath..."
    $webClient.DownloadFile("$ftpHost$ftpFilePath", $localPath)

    Write-Host "T�l�chargement r�ussi."
} catch {
    $erreur = $_.Exception.Message
    Write-Error "Erreur lors du t�l�chargement de l'archive : $erreur"

    # Envoi d'un email d'erreur
    Envoyer-Email -sujet "Erreur de t�l�chargement FTP" -corps "Une erreur est survenue lors du t�l�chargement de l'archive depuis $ftpHost$ftpFilePath : $erreur"
    exit 1
}

# V�rification de l'int�grit� du fichier t�l�charg�
if (-Not (Test-Path $localPath)) {
    $message = "Le fichier n'a pas �t� t�l�charg� correctement."
    Write-Error $message

    # Envoi d'un email d'erreur
    Envoyer-Email -sujet "Erreur de fichier manquant" -corps $message
    exit 1
}

Write-Host "Processus termin� avec succ�s."