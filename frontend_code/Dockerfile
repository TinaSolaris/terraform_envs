FROM busybox:1.35

RUN adduser -D stud
USER stud
WORKDIR /home/stud

COPY src/ .
WORKDIR /home/stud/static

USER root
RUN chown -R stud:stud /home/stud
USER stud

COPY entrypoint.sh /entrypoint.sh

USER root
RUN chmod 777 /entrypoint.sh
USER stud

EXPOSE 3000

ENV BACKEND_URL=localhost:8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/busybox", "httpd", "-f", "-v", "-p", "3000"]