from flask import Flask, render_template, request
from flask.ext.sqlalchemy import SQLAlchemy
import sys
import logging

from flask.ext.heroku import Heroku



app = Flask(__name__)
#app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://localhost/lions_tracks'
#db = SQLAlchemy(app)
heroku = Heroku(app)
db = SQLAlchemy(app)

app.logger.addHandler(logging.StreamHandler(sys.stdout))
app.logger.setLevel(logging.ERROR)
# Create our database model
class User(db.Model):
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key=True)
    #email = db.Column(db.String(120), unique=True)
    sex = db.Column(db.String(1))
    age = db.Column(db.Integer)
    height = db.Column(db.Integer)
    weight = db.Column(db.Integer)
    activity = db.Column(db.Integer)
    sleep = db.Column(db.Integer)
    health = db.Column(db.Integer)

    def __init__(self, sex, age, height, weight, acitivity, sleep, health):
        self.sex = sex
        self.age = age
        self.height = height
        self.weight = weight
        self.activity = activity
        self.sleep = sleep
        self.health = health

   # def __repr__(self):
   #     return '<E-mail %r>' % self.email

# Set "homepage" to index.html
@app.route('/')
def index():
    return render_template('index.html')

# Save e-mail to database and send to success page
@app.route('/upload', methods=['POST'])
def upload():
    email = None
    if request.method == 'POST':
        sex = request.form['sex']
        age = request.form['age']
        height = request.form['height']
        weight = request.form['weight']
        activity = request.form['activity']
        sleep = request.form['sleep']
        health = request.form['health']


        # Check that email does not already exist (not a great query, but works)
        #if not db.session.query(User).filter(User.email == email).count():
        reg = User(sex, age, height, weight, acitivity, sleep, health)
        db.session.add(reg)
        db.session.commit()
            #return render_template('success.html')
    return render_template('index.html')

if __name__ == '__main__':
    app.debug = True
    app.run()