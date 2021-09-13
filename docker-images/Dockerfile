FROM python:3.8

RUN pip install requests jinja2
WORKDIR /code
COPY . /code
ENTRYPOINT ["/bin/bash", "/code/entrypoint.sh"]
