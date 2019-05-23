echo "Installing ldap..."
apt install ldap-utils

echo "Inserting schema in LDAP server"
ldapadd -Y EXTERNAL -H ldapi:/// -f schema.ldif 
echo "Inserting base"
#                set here your user      set here password
ldapadd -c -x -D "cn=admin,dc=nodomain" -w admin -f base.ldif
echo "Setting cron"
# Every 15 minutes update & remove the entries
(crontab -l ; echo "*/15 * * * * $(pwd)/scan_hosts.sh") | crontab -
(crontab -l ; echo "*/15+1 * * * * $(pwd)/cleaner.sh") | crontab -
