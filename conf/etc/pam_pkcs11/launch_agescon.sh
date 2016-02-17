#!/bin/sh
BINDDN="cn=srvc_letSAS,ou=Usuarios,ou=Admin,ou=Administrativo,dc=dmsas,dc=sda,dc=sas,dc=junta-andalucia,dc=es"
BINDPW="5*-PON69rW"
XAUTH="/var/run/slim.auth"
AGESCON="https://sgi.sas.junta-andalucia.es/agescon/inicioLogin.xhtml"
PID="/var/run/agescon.pid"

launch_midori () {
	(
        export XAUTHORITY=/var/run/slim.auth
        export DISPLAY=:0.0
        jwm &
        midori -p -e Fullscreen -a "$AGESCON" &
	)
}

echo $$ > $PID
# Get public data from DNIe tool
DNI=$(dnie-tool -d | grep DNI | awk '{print $3}')

USER=$(ldapsearch -x -LLL -D $BINDDN -w $BINDPW -b "DC=dmsas,DC=sda,DC=sas,DC=junta-andalucia,DC=es" -s sub -H ldap://dmsas.sda.sas.junta-andalucia.es "(employeeNumber=$DNI)" sAMAccountName)

# Get sAMACountName from ldap answer
USER=$(echo $USER | awk '{print $5}')

if [[ "$USER" != "" ]]; then
	launch_midori
fi

exit 0

