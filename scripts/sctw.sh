#!/bin/sh

# Copyright 2018 Moviuro <moviuro+git@gmail.com>
# Uses https://sunrise-sunset.org/api
# Uses https://www.tedunangst.com/flak/post/sct-set-color-temperature

# sctw is a sct wrapper
# takes $SCTW_LAT $SCTW_LNG for position, and calculates a comfortable screen
# temperature at the time it's run.
# requires curl(1), jq(1)

myname="$(basename "$0")"
today="$(date "+%Y-%m-%d")"

: "${SCTW_CONFIG:="${XDG_CONFIG_HOME:=$HOME/.config}/$myname.rc"}"
: "${TMPDIR:="/tmp"}"

_values="sunrise sunset civil_twilight_begin civil_twilight_end"

if [ -r "$SCTW_CONFIG" ]; then
  . "$SCTW_CONFIG"
fi

if [ -n "$SCTW_LAT" ] && [ -n "$SCTW_LNG" ]; then
  :
else
  echo "Setting lat and lon to Trondheim" >&2
  SCTW_LAT="63.44"
  SCTW_LNG="10.42"
fi

umask 077
mkdir "$TMPDIR/$myname" >/dev/null 2>&1
[ -d "$TMPDIR/$myname" ] || exit 3
myfile="$TMPDIR/$myname/$today.$SCTW_LAT-$SCTW_LNG"
mytmpfile="$myfile.tmp"
if [ -r "$myfile" ]; then
  :
else
  # Remove previous data: it's not needed anymore
  rm "${TMPDIR:?WOW}/${myname:?DANGER}/"*
  # Store and generate today's data
  curl -s \
   "https://api.sunrise-sunset.org/json?lat=${SCTW_LAT}&lng=${SCTW_LNG}&formatted=0&date=${today}" \
   > "$mytmpfile"
  for item in $_values; do
    printf '%s=%s\n' "$item" "$(jq .results.$item < "$mytmpfile")"
  done > "$myfile"
  . "$myfile"
  if [ -z "$sunrise" ] || [ -z "$sunset" ] || [ -z "$civil_twilight_begin" ] ||
    [ -z "$civil_twilight_end" ]; then
    echo "Missing value(s) in $myfile!" >&2
    mv "$myfile" "$myfile".broken
    exit 4
  fi
  if man date 2>&1 | grep -q GNU; then
    printf '%s=%s\n' \
     civil_twilight_begin "$(date -d "$civil_twilight_begin" +%s)" \
     sunrise              "$(date -d "$sunrise" +%s)" \
     sunset               "$(date -d "$sunset" +%s)" \
     civil_twilight_end   "$(date -d "$civil_twilight_end" +%s)" > "$myfile"
  else
    echo "Unsupported date(1), help me fix it." 2>&1
    exit 5
  fi
fi

. "$myfile"

: "${SCTW_DAY_K:=6500}"
: "${SCTW_NIGHT_K:=4500}"
# We're doing something linear from NIGHT_K to DAY_K from civil_twilight_begin
# to sunrise; and from sunset to civil_twilight_end.
Kdiff="$(( SCTW_DAY_K - SCTW_NIGHT_K ))"

now="$(date "+%s")"
night="$(( now < civil_twilight_begin ))" # It's dark
dawn="$(( now < sunrise ))"               # It's getting brighter
day="$(( now < sunset ))"                 # It's day
dusk="$(( now < civil_twilight_end ))"    # It's getting darker
if [ "$night" -eq 1 ]; then
  sct "$SCTW_NIGHT_K"
elif [ "$dawn" -eq 1 ]; then
  timediff="$(( now - civil_twilight_begin ))"
  sct "$(( SCTW_NIGHT_K + Kdiff * timediff / ( sunrise - civil_twilight_begin ) ))"
elif [ "$day" -eq 1 ]; then
  sct "$SCTW_DAY_K"
elif [ "$dusk" -eq 1 ]; then
  timediff="$(( civil_twilight_end - now ))"
  sct "$(( SCTW_NIGHT_K + Kdiff * timediff / ( civil_twilight_end - sunset ) ))"
else
  sct "$SCTW_NIGHT_K"
fi

