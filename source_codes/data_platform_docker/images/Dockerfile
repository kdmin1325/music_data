From python:3.8.0

WORKDIR /usr/src/app
COPY . .

RUN pip install --upgrade pip setuptools wheel
RUN pip install -r ./requirements.txt

EXPOSE 5000

CMD ["python", "./app.py"]