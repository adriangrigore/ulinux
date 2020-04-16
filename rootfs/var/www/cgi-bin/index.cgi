#!/bin/sh

env > /tmp/env

oIFS=$IFS
IFS=$'\n'
q=${REQUEST_URI}
t="Files"
t=$(basename ${q})
h="&#9664; ${t}"
if [ $t == "/" ]; then
  t="Files"
  h="${t}"
fi

echo "Content-type: text/html"
echo ""

cat <<EOF
<html>
<head>
<title>${t}</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta charset="UTF-8">
<style>
body {
  font: 1rem/1.5 arial;
  margin: 0;
}

h1 {
  font-size: 1rem;
  text-transform: capitalize;
  margin: 0;
  background: #444;
}

a {
  color: #444;
  text-decoration: none;
  display: block;
  padding: 0.5rem;
}

h1 a {
  color: #fff;
}

.files a {
  border-top: 1px solid #ddd;
}

.files a.d {
  font-weight: bold;
}
</style>
</head>
<body>
<h1><a href="..">${h}</a></h1>
<div class="files">
EOF

cd "..${q}"
ls=$(ls --group-directories-first)

for f in $ls; do
  c="f"
  if [[ -d ${f} ]]; then
    c="d"
  fi
  echo "<a class=\"${c}\" href=\"//${HTTP_HOST}${REQUEST_URI}${f}\">${f}</a>"
done

cat <<EOF
</div>
</body>
</html>
EOF

IFS=$oIFS
exit 0
