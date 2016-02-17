#!/bin/sh
if [ -f /etc/sysconfig/resolution.info ]; then
	. /etc/sysconfig/resolution.info
fi
[ "$RESOLUTION" == "" ] && RESOLUTION="1024x768"
xrandr --output default --mode $RESOLUTION
xrandr --output VGA-0 --mode $RESOLUTION
xrandr --output DVI-0 --mode $RESOLUTION

export LANG="es_ES.UTF-8"
export LC_ALL="es_ES.UTF-8"
export MOZ_PLUGIN_PATH="/usr/lib/mozilla/plugins"
xset +fp /usr/share/fonts/dejavu/
xset s off
# No accel for mouse (default 2/1)
xset m 1/2 4
xset -dpms
. /etc/proxy.conf
if [ "$proxy_value" != "" ]; then
    source /var/www/cgi-bin/functions.sh
    SASProxy
fi
( xautolock -time 15 -locker slimlock -notify 15 -notifier "Xdialog --title 'Bloqueo de pantalla' --infobox 'El equipo se bloqueara en 15 segundos' 0 0 15000" -killtime 50 -killer poweroff & )
xrdb -load ~/.Xresources
setxkbmap es
(sleep 3 && conky -d) &
#noticias.sh 2>/dev/null 1>&2 
#informacion_de_interes.sh 2>/dev/null 1>&2
if [ "$RESOLUTION" == "1920x1080" ]
then
	cp /etc/skel/.config/tint2/tint2rc-1080 $HOME/.config/tint2/tint2rc
elif [ "$RESOLUTION" == "1280x720" ]
then
	cp /etc/skel/.config/tint2/tint2rc-720p $HOME/.config/tint2/tint2rc
else	
	cp /etc/skel/.config/tint2/tint2rc-720 $HOME/.config/tint2/tint2rc
fi

tint2 &
jwm
