#!/bin/ash

[ -f "content.sh" ] && . content.sh

# Query STRING processing
IFS='=&'
#parm=($QUERY_STRING)
i=0
for param in $QUERY_STRING; do
    eval parm_${i}=\$param
    i=$(($i + 1))
done
unset IFS

echo 'Content-type: text/html'
echo ''
echo '<!DOCTYPE html>'
echo '<html lang="es">'
echo '<head>'
echo '<meta charset="utf-8">'
echo '<meta http-equiv="X-UA-Compatible" content="IE=edge">'
echo '<meta name="viewport" content="width=device-width, initial-scale=1">'
echo '<meta name="description" content="Panel de control - LeTSAS">'
echo '<meta name="author" content="Gerardo Puerta gerardo.puerta@juntadeandalucia.es">'
echo '<link rel="shortcut icon" href="/favicon.ico">'
echo '<title>Panel de Control - LeTSAS</title>'
echo '<link href="/css/bootstrap.min.css" rel="stylesheet">'
echo '<link href="/css/dashboard.css" rel="stylesheet">'
echo '</head>'
echo '<body>'
echo '<div class="navbar navbar-inverse navbar-fixed-top" role="navigation">'
echo '<div class="container-fluid">'
echo '<div class="navbar-header">'
echo '<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">'
echo '<span class="sr-only">Toggle navigation</span>'
echo '<span class="icon-bar"></span>'
echo '<span class="icon-bar"></span>'
echo '<span class="icon-bar"></span>'
echo '</button>'
echo '<a class="navbar-brand" href="#">LeTSAS <small>4.0</small></a>'
echo '</div>'
echo '<div class="navbar-collapse collapse">'
echo '<ul class="nav navbar-nav navbar-right" id="main-nav">'
echo '<li><a href="?dashboard=1&vg=1">Inicio</a></li>'
echo '<li><a href="?servicios=1&vg=1">Servicios</a></li>'
echo '<li><a href="?informacion=1&identidad=1">Informaci&oacute;n</a></li>'
echo '<li><a href="?configuracion=1&vg=1">Configuraci&oacute;n</a></li>'
echo '<li><a href="?ayuda=1">Ayuda</a></li>'
echo '</ul>'
echo '</div> <!-- navbar -->'
echo '</div> <!-- container -->'
echo '</div> <!-- navigation -->'
echo '<div class="container-fluid">'
echo '<div class="row">'
echo '<div class="col-sm-3 col-md-2 sidebar">'
echo '<ul class="nav nav-sidebar" id="sidebar">'
echo '<li><a href="?dashboard=1&vg=1">Vista General</a></li>'
echo '<li><a href="?dashboard=1&memoria=1">Memoria</a></li>'
echo '<li><a href="?dashboard=1&cpu=1">CPU</a></li>'
echo '<li><a href="?dashboard=1&disco=1">Disco</a></li>'
echo '<li><a href="?informacion=1&identidad=1">Identidad</a></li>'
echo '<li><a href="?informacion=1&bios=1">BIOS</a></li>'
echo '<li><a href="?informacion=1&sistema=1">Sistema</a></li>'
echo '<li><a href="?informacion=1&pym=1">Procesador y memoria</a></li>'
echo '<li><a href="?informacion=1&red=1">Informaci&oacute;n de red</a></li>'
echo '<li><a href="?informacion=1&soporte=1">Soporte</a></li>'
echo '<li><a href="?configuracion=1&vg=1">Estado general</a></li>'
echo '<li><a href="?configuracion=1&Nombre=1">Nombre del terminal</a></li>'
echo '<li><a href="?configuracion=1&Resolucion=1">Resoluci&oacute;n de la pantalla</a></li>'
echo '<li><a href="?configuracion=1&Red=1">Configuraci&oacute;n de red</a></li>'
echo '<li><a href="?configuracion=1&Impresion=1">Impresi&oacute;n del terminal</a></li>'
echo '<li><a href="?servicios=1&vg=1">Estado general</a></li>'
echo '<li><a href="?servicios=1&Slim=1">Inicio de sesi&oacute;n</a></li>'
echo '<li><a href="?servicios=1&LPD=1">Servicio de impresi&oacute;n</a></li>'
echo '<li><a href="?servicios=1&Adlagent=1">Agente Altiris</a></li>'
echo '<li><a href="?servicios=1&Red=1">Servicio de red</a></lib>'
echo '<li><a href="?servicios=1&Xinetd=1">Xinetd</a></li>'
echo '</ul>'
echo '</div> <!-- Sidebar -->'
if [ "$parm_0" == "" ]; then
    parm_0="dashboard"
    parm_2="vg"
fi
content ${parm_0} ${parm_2} 
echo '</div> <!-- Row -->'
echo '</div> <!-- Container -->'

echo '<!-- Bootstrap core JavaScript'
echo '================================================== -->'
echo '<!-- Placed at the end of the document so the pages load faster -->'
echo '<script src="/js/jquery.min.js"></script>'
echo '<script src="/js/bootstrap.min.js"></script>'
echo '<script src="/js/docs.min.js"></script>'
echo '<script>'
echo '$(function() {'
echo "\$(\"ul#main-nav li a[href*='${par_0}']\").parent().addClass(\"active\");"
echo "\$(\"ul#sidebar li\").hide();"
echo "\$(\"ul#sidebar li a[href*='${parm_0}']\").parent().show();"
echo "\$(\"ul#sidebar li a[href*='${parm_2}']\").parent().addClass(\"active\");"


echo '});'
echo '</script>'
echo '</body>'
echo '</html>'

exit 0
