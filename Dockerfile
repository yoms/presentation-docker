FROM httpd:2.4

COPY data /usr/local/apache2/htdocs/
COPY presentation.md /usr/local/apache2/htdocs/presentation.md
RUN cat /usr/local/apache2/htdocs/header.txt > /usr/local/apache2/htdocs/index.html
RUN cat /usr/local/apache2/htdocs/presentation.md >> /usr/local/apache2/htdocs/index.html
RUN cat /usr/local/apache2/htdocs/footer.txt >> /usr/local/apache2/htdocs/index.html
