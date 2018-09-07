#!/bin/env bash

mvn clean site -DvdmSite

sed -i.bak 's/<li class="active "><\/li>/<li class="active ">Reports<\/li>/g' target/site/reports.html
rm target/site/reports.html.bak
sed -i.bak 's/x2013; <\/title>/x2013; Reports<\/title>/g' target/site/reports.html
rm target/site/reports.html.bak

sed -i.bak 's/<li class="active "><\/li>/<li class="active ">Talks<\/li>/g' target/site/talks.html
rm target/site/talks.html.bak
sed -i.bak 's/x2013; <\/title>/x2013; Talks<\/title>/g' target/site/talks.html
rm target/site/talks.html.bak

sed -i.bak 's/<li class="active "><\/li>/<li class="active ">Books \&amp; Similar<\/li>/g' target/site/publications-books.html
rm target/site/publications-books.html.bak
sed -i.bak 's/x2013; <\/title>/x2013; Books \&amp; Similar<\/title>/g' target/site/publications-books.html
rm target/site/publications-books.html.bak

sed -i.bak 's/<li class="active "><\/li>/<li class="active ">Articles<\/li>/g' target/site/publications-articles.html
rm target/site/publications-articles.html.bak
sed -i.bak 's/x2013; <\/title>/x2013; Articles<\/title>/g' target/site/publications-articles.html
rm target/site/publications-articles.html.bak

sed -i.bak 's/<li class="active "><\/li>/<li class="active ">in Proceedings<\/li>/g' target/site/publications-inproceedings.html
rm target/site/publications-inproceedings.html.bak
sed -i.bak 's/x2013; <\/title>/x2013; in Proceedings<\/title>/g' target/site/publications-inproceedings.html
rm target/site/publications-inproceedings.html.bak

sed -i.bak 's/<li class="active "><\/li>/<li class="active ">Standards<\/li>/g' target/site/publications-standards.html
rm target/site/publications-standards.html.bak
sed -i.bak 's/x2013; <\/title>/x2013; Standards<\/title>/g' target/site/publications-standards.html
rm target/site/publications-standards.html.bak

sed -i.bak 's/<li class="active "><\/li>/<li class="active ">Patents<\/li>/g' target/site/publications-patents.html
rm target/site/publications-patents.html.bak
sed -i.bak 's/x2013; <\/title>/x2013; Patents<\/title>/g' target/site/publications-patents.html
rm target/site/publications-patents.html.bak

sed -i.bak 's/<li class="active "><\/li>/<li class="active ">Supervision<\/li>/g' target/site/teaching-supervision.html
rm target/site/teaching-supervision.html.bak
sed -i.bak 's/x2013; <\/title>/x2013; Supervision<\/title>/g' target/site/teaching-supervision.html
rm target/site/teaching-supervision.html.bak


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

#sed -i.bak 's/<li class="active "><\/li>/<li class="active ">Research Library<\/li>/g' target/site/research-library.html
#rm target/site/research-library.html.bak
#sed -i.bak 's/x2013; <\/title>/x2013; Research Library<\/title>/g' target/site/research-library.html
#rm target/site/research-library.html.bak



