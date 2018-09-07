#!/bin/env bash

mvn clean site

sed -i.bak 's/<li class="active "><\/li>/<li class="active ">Research Notes - Policy-based Management<\/li>/g' target/site/research-notes-policy.html
rm target/site/research-notes-policy.html.bak
sed -i.bak 's/x2013; <\/title>/x2013; Research Notes - Policy-based Management<\/title>/g' target/site/research-notes-policy.html
rm target/site/research-notes-policy.html.bak

sed -i.bak 's/<li class="active "><\/li>/<li class="active ">Research Notes - Cybernetics<\/li>/g' target/site/research-notes-cybernetics.html
rm target/site/research-notes-cybernetics.html.bak
sed -i.bak 's/x2013; <\/title>/x2013; Research Notes - Cybernetics<\/title>/g' target/site/research-notes-cybernetics.html
rm target/site/research-notes-cybernetics.html.bak

sed -i.bak 's/<li class="active "><\/li>/<li class="active ">Research Notes - INA<\/li>/g' target/site/research-notes-ina.html
rm target/site/research-notes-ina.html.bak
sed -i.bak 's/x2013; <\/title>/x2013; Research Notes - INA<\/title>/g' target/site/research-notes-ina.html
rm target/site/research-notes-ina.html.bak

sed -i.bak 's/<li class="active "><\/li>/<li class="active ">Research Notes - Internet History<\/li>/g' target/site/research-notes-internet-history.html
rm target/site/research-notes-internet-history.html.bak
sed -i.bak 's/x2013; <\/title>/x2013; Research Notes - Internet History<\/title>/g' target/site/research-notes-internet-history.html
rm target/site/research-notes-internet-history.html.bak

rm -fr ../docs/*
mvn site:stage
