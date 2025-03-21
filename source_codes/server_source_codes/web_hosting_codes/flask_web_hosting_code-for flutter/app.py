from flask import Flask, send_file
from flask import send_from_directory
from flask import render_template
from flask_cors import CORS
import ssl

app = Flask(__name__, )
# app = Flask(__name__, template_folder='templates')
CORS(app)

FLUTTER_WEB_APP = 'templates'

@app.route('/')
def render_page():
    print(' ddd')
    return render_template('index.html')


@app.route('/web/')
def render_page_web():
    return render_template('index.html')


@app.route('/web/<path:name>')
def return_flutter_doc(name):

    datalist = str(name).split('/')
    DIR_NAME = FLUTTER_WEB_APP

    if len(datalist) > 1:
        for i in range(0, len(datalist) - 1):
            DIR_NAME += '/' + datalist[i]

    return send_from_directory(DIR_NAME, datalist[-1])


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=443)

