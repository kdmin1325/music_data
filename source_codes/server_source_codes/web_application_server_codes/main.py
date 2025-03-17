import os.path
import werkzeug
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token
from login import _login
from component_classes.component import User
from datetime import datetime
from register_feature import _register
from database_codes.database import getSongData, getSongPartData, insertReviewTable, getReviewData, isCheckId, \
    getReviewByUserIdSongId, makeSongScoreTable
from flask import send_from_directory
from flask import render_template
from flask_restx import Api, Resource


def create_app():

    app = Flask(__name__)

    @app.route('/')
    def render_page():
        return render_template('index.html')

    @app.route('/web/')
    def render_page_web():
        return render_template('index.html')

    #플러터 웹 호스팅 함수.
    @app.route('/web/<path:name>')
    def return_flutter_doc(name):

        datalist = str(name).split('/')
        DIR_NAME = FLUTTER_WEB_APP

        if len(datalist) > 1:
            for i in range(0, len(datalist) - 1):
                DIR_NAME += '/' + datalist[i]

        return send_from_directory(DIR_NAME, datalist[-1])

    ## 아래 API에 관해서는 docs에 대한 내용을 작성하기 위한 것
    api = Api(app, version='1.0', title='API 문서', description='Swagger  문서', doc="/api-docs")

    user_api = api.namespace('user', description='유저 관련 API')
    song_api = api.namespace('song', description='노래 관련 API')
    review_api = api.namespace('review', description='평가 관련 API')
    search_api = api.namespace('search', description='검색 관련 API')


    ## 로그인 기능 중 액세스 토큰을 발급하기 위한 것
    app.config['JWT_SECRET_KEY'] = 'minseopark'
    jwt = JWTManager(app)

    ## CORS 적용을 위한 것, 보안을 위해 특정 IP만 허용을 시킬 수 있음.
    CORS(app)


    UPLOAD_FOLDER = 'uploads'
    UPLOAD_FOLDER_IMAGES = 'uploads/images'

    if not os.path.exists(UPLOAD_FOLDER):
        os.makedirs(UPLOAD_FOLDER)
    if not os.path.exists(UPLOAD_FOLDER_IMAGES):
        os.makedirs(UPLOAD_FOLDER_IMAGES)

    app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
    app.config['UPLOAD_FOLDER_IMAGES'] = UPLOAD_FOLDER_IMAGES

    FLUTTER_WEB_APP = 'templates'

    @user_api.route('/login')
    class User2(Resource):
        def get(self):
            return 'Hello world!'

    @user_api.route('/register')
    class User3(Resource):
        def post(self):
            return 'Hello World!'

    @user_api.route('/getUserName')
    class GetUserName(Resource):
        def get(self):
            return 'Hello World!'

    @user_api.route('/isIdDuplicated')
    class IsIdDuplicated(Resource):
        def get(self):
            return 'Hello World!'

    @song_api.route('/')
    class Song1(Resource):
        def get(self):
            return 'Hello world!'

    @song_api.route('/upload')
    class Upload(Resource):
        def get(self):
            return 'Helo'

    @song_api.route('/uploadFiles')
    class UploadFiles(Resource):
        def get(self):
            return 'Hello'

    @song_api.route('/insertSong')
    class InsertSong(Resource):
        def get(self):
            return 'Hello'

    @song_api.route('/insertScore')
    class InsertScore(Resource):
        def get(self):
            return 'Hello'

    @song_api.route('/getSongScore')
    class GetSongScore(Resource):
        def get(self):
            return 'Hello'

    @song_api.route('/getSongList')
    class GetSongList(Resource):
        def get(self):
            return 'Hello'

    @song_api.route('getSongPart')
    class GetSongPart(Resource):
        def get(self):
            return 'Hello'

    @review_api.route('/')
    class Review1(Resource):
        def get(self):
            return 'Hello world!'

    @review_api.route('/saveReview')
    class SaveReview(Resource):
        def post(self):
            return 'Hello world'

    @review_api.route('/getReview')
    class GetReview(Resource):
        def post(self):
            return 'Hello world'

    @review_api.route('/getReviewDataByUserIdSongId')
    class GetReviewDataByUserIdSongId(Resource):
        def post(self):
            return 'Hello world'

    @search_api.route('/getSearchText')
    class Search(Resource):
        def post(self):
            return 'Hello world'

    ### 업로드 기능을 하는 라우터
    @app.route('/api/song/upload', methods=['POST'])
    def upload_file():
        if 'file' not in request.files:
            return jsonify({'error': '파일이 요청에 포함되지 않았습니다.'}), 400

        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': '선택된 파일이 없습니다.'}), 400

        if file:
            timestamp = datetime.now().strftime("%Y%m%d%H%M%S%f")
            original_filename = werkzeug.utils.secure_filename(file.filename)
            filename = f"{timestamp}_{original_filename}"
            save_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file.save(save_path)

            return jsonify({'message': '파일 업로드 성공', 'savepath': save_path}), 200

        return jsonify({'error': '파일 업로드 실패'}), 500

    ### 업로드 기능을 하는 라우터
    @app.route('/api/song/uploadFiles', methods=['POST'])
    def upload_files():
        # 'files'라는 key 아래에 파일들이 들어있다고 가정
        if 'files' not in request.files:
            return jsonify({'error': '파일이 요청에 포함되지 않았습니다.'}), 400

        files = request.files.getlist('files')

        if not files or all(file.filename == '' for file in files):
            return jsonify({'error': '선택된 파일이 없습니다.'}), 400

        saved_files = []
        for file in files:
            if file:
                timestamp = datetime.now().strftime("%Y%m%d%H%M%S%f")
                original_filename = werkzeug.utils.secure_filename(file.filename)
                filename = f"{timestamp}_{original_filename}"
                save_path = os.path.join(app.config['UPLOAD_FOLDER_IMAGES'], filename)
                file.save(save_path)
                saved_files.append(save_path)

        if saved_files:
            return jsonify({'message': '파일 업로드 성공', 'savepaths': saved_files}), 200

        return jsonify({'error': '파일 업로드 실패'}), 500

    ### 곡 넣는 API
    @app.route('/api/song/insertSong', methods=['POST'])
    def insertSong():

        song_data = request.json

        song_name = song_data['songName']
        composer = song_data['composer']
        duration = song_data['duration']
        upload_path = song_data['upload_path']

        from insertSong import insertSong

        try:
            song_id = insertSong(song_name, duration, composer, upload_path)
            os.remove(upload_path)
            return jsonify({'message': 'success', 'song_id': song_id})
        except Exception as e:
            return jsonify({'message': 'error'})

    ### 악보 넣는 API
    @app.route('/api/song/insertScore', methods=['POST'])
    def insertScore():
        print()
        print()
        print()
        print()
        print()
        print()

        print('=' * 50)
        print('악보 삽입 시작..')
        score_data = request.json

        print(score_data)

        song_id = score_data['song_id']
        song_part_id = score_data['song_part_id']
        score_path_list = score_data['url']
        print(score_data['url'])
        sequence = score_data['sequence']
        song_name = score_data['song_name']

        print(song_id)
        print(song_name)
        print(score_path_list)
        print(song_part_id)

        from insertSong import insertScore
        try:
            insertScore(song_id=song_id, song_name=song_name, image_file_path_list=[score_path_list],
                        song_part_id=song_part_id)
            print('악보 삽입 완료')
            print()
            for i in score_path_list:
                os.remove(i)
            return jsonify({'message': 'success'})
        except Exception as e:
            return jsonify({'message': 'error'})

    ### 악보 얻는 API
    @app.route('/api/song/getSongScore', methods=['GET'])
    def getSongScore():

        song_id = request.args.get('song_id')
        song_part_id = request.args.get('song_part_id')

        print('sequence')
        print(request.args.get('sequence'))
        print(request.args.get)

        print('호출')

        from database_codes.database import getSongScoreData

        try:
            sequence_list, score_url_list = getSongScoreData(song_id, song_part_id)
            return jsonify({
                'sequence_list': sequence_list,
                'score_url_list': score_url_list
            }), 200
        except Exception as e:
            return jsonify({
                'message': 'error'
            }), 401

    ### 로그인 ROUTER
    @app.route('/api/user/login', methods=['get'])
    def api_login():
        try:
            user_id = request.args.get('user_id')
            user_pwd = request.args.get('user_pwd')

            print('로그인 시도: ', user_id, user_pwd)

            isLogin = _login(user_id, user_pwd)

            if isLogin == 1:
                return jsonify(
                    {'message': '로그인 실패(아이디 또는 비밀번호 오류)'}, {"status": "error"}
                ), 401
            elif isLogin == 0:

                access_token = create_access_token(identity=user_id)
                from database_codes.database import getUserAdmin
                admin = getUserAdmin(user_id)

                return jsonify(
                    {'message': '로그인 성공'}, {'status': 'success'}, {'access_token': access_token}, {'admin': admin}
                ), 200
            else:
                return jsonify(
                    {'message': '로그인 실패(아이디 또는 비밀번호 오류)'}, {"status": "error"}
                ), 401
        except:
            return jsonify(
                {'message': '로그인 실패(아이디 또는 비밀번호 오류 System Error)'}, {"status": "error"}
            ), 401

    ### 회원가입 ROUTER
    @app.route('/api/user/register', methods=['post'])
    def api_register():

        now = datetime.now()
        formatted_now = now.strftime("%Y-%m-%d")

        new_user_data = request.get_json()
        try:
            new_user = User(
                user_id=new_user_data['user_id'],
                user_pwd=new_user_data['user_pwd'],
                user_name=new_user_data['user_name'],
                department=new_user_data['department'],
                job=new_user_data['job'],
                university=new_user_data['university'],
                ph_num=new_user_data['ph_num'],
                created_date=formatted_now,
                modified_date=formatted_now
            )
        except:
            return jsonify({'message': '회원가입 정보를 정확히 기입해주세요.'}), 401

        print(new_user_data['user_pwd'])

        isRegister = _register(new_user)

        if isRegister == 1:
            return jsonify({'message': '회원가입 실패', 'status': 'error'}), 401
        elif isRegister == 0:
            return jsonify({'message': '회원가입 성공'}, {'status': 'success'}), 200

    ### 아이디 중복 검색 ROUTER
    @app.route('/api/user/isIdDuplicated', methods=['get'])
    def is_id_duplicated():
        user_id = request.args.get('user_id')
        check_user_id = isCheckId(user_id)

        if check_user_id == '':
            return jsonify(
                {
                    'message': 'not duplicate',
                }
            ), 200
        else:
            return jsonify(
                {
                    'message': 'duplicate'
                }
            ), 401

    ### 곡 리스트 얻는 ROUTER
    @app.route('/api/song/getSongList', methods=['get'])
    def get_song_list():
        page_number = request.args.get('page_number')

        try:
            song_id_list, song_name_list, duration_list, composer_list = getSongData(page_number=page_number)
        except Exception as e:
            return 401

        song_data = {
            'song_id_list': song_id_list,
            'song_name_list': song_name_list,
            'duration_list': duration_list,
            'composer_list': composer_list
        }

        return jsonify(song_data), 200

    ### 곡 파트 얻는 ROUTER
    @app.route('/api/song/getSongPart', methods=['get'])            #song id 지정
    def get_song_part():
        song_id = request.args.get('song_id')

        try:
            song_part_id_list, part_url_list, part_sequence_list, is_score_list = getSongPartData(song_id=song_id)
        except Exception as e:
            return 401

        # part 정보 sorting?
        song_data = {
            'song_part_id_list': song_part_id_list,
            'part_url_list': part_url_list,
            'part_sequence': part_sequence_list,
            'is_score_list': is_score_list
        }

        return jsonify(song_data), 200

    ### 리뷰 저장하는 ROUTER
    @app.route('/api/review/saveReview', methods=['post'])
    def save_review_data():
        new_review_data = request.json

        from component_classes.component import Review

        try:
            review_data = Review(
                user_id=new_review_data['user_id'],
                song_id=new_review_data['song_id'],
                song_part_seq=new_review_data['song_part_seq'],
                tone_score=new_review_data['tone_score'],
                legato_score=new_review_data['legato_score'],
                representation_score=new_review_data['representation_score'],
                phrasing_score=new_review_data['phrasing_score'],
                melody_score=new_review_data['melody_score'],
                music_score=new_review_data['music_score'],
                voicing_score=new_review_data['voicing_score'],
                note_score=new_review_data['note_score'],
                dynamic_score=new_review_data['dynamic_score'],
                dynamic_change_score=new_review_data['dynamic_change_score'],
                tempo_score=new_review_data['tempo_score'],
                tempo_change_score=new_review_data['tempo_change_score'],
                articulation_score=new_review_data['articulation_score'],
                rhythm_score=new_review_data['rhythm_score'],
                pedal_score=new_review_data['pedal_score']
            )

        except Exception as e:
            return jsonify({'message': '평가 정보를 정확히 기입해주세요.'}), 402

        result = insertReviewTable(review_data)

        if result == 1:
            return jsonify({'message': '평가정보 저장 실패', 'status': 'error'}), 401
        elif result == 0:
            return jsonify({'message': '평가정보 저장 성공'}, {'status': 'success'}), 200

    ### 리뷰 데이터 얻는 ROUTER
    @app.route('/api/review/getReview', methods=['get'])
    def get_review_data():
        user_id = request.args.get('user_id')

        try:
            song_name_list, duration_list, composer_list, sequence_list, tone_score_list, legato_score_list, representation_score_list, phrasing_score_list, melody_score_list, music_score_list, voicing_score_list, note_score_list, dynamic_score_list, dynamic_change_score_list, tempo_score_list, tempo_change_score_list, articulation_score_list, rhythm_score_list, pedal_score_list = getReviewData(
                user_id)
        except Exception as e:
            return '401'

        # part 정보 sorting?
        review_data = {
            'song_name_list': song_name_list,
            'duration_list': duration_list,
            'sequence_list': sequence_list,
            'tone_score_list': tone_score_list,
            'legato_score_list': legato_score_list,
            'representation_score_list': representation_score_list,
            'phrasing_score_list': phrasing_score_list,
            'melody_score_list': melody_score_list,
            'music_score_list': music_score_list,
            'voicing_score_list': voicing_score_list,
            'note_score_list': note_score_list,
            'dynamic_score_list': dynamic_score_list,
            'dynamic_change_score_list': dynamic_change_score_list,
            'tempo_score_list': tempo_score_list,
            'tempo_change_score_list': tempo_change_score_list,
            'articulation_score_list': articulation_score_list,
            'rhythm_score_list': rhythm_score_list,
            'pedal_score_list': pedal_score_list
        }

        print(review_data)
        return jsonify(review_data), '200'

    ### 유저 아이디로 리뷰 데이터 얻는 ROUTER
    @app.route('/api/review/getReviewDataByUserIdSongId', methods=['GET'])
    def getReviewDataByUserIdSongId():

        user_id = request.args.get('user_id')
        song_id = request.args.get('song_id')

        seq_list = getReviewByUserIdSongId(song_id, user_id)

        return jsonify(
            {
                'sequence_list': seq_list
            }
        )

    ### 검색 기능을 위한 ROUTER
    @app.route('/api/search/getSearchText', methods=['GET'])
    def getSearchText():
        search_text = request.args.get('search_text')

        from database_codes.database import getSearchData
        # song_id_list, song_name_list, song_duration_list, song_composer_list
        try:

            song_id_list = []
            song_name_list = []
            song_duration_list = []
            song_composer_list = []

            song_id_list, song_name_list, song_duration_list, song_composer_list = getSearchData(search_text)
            return jsonify({
                'song_id_list': song_id_list,
                'song_name_list': song_name_list,
                'song_duration_list': song_duration_list,
                'song_composer_list': song_composer_list
            }), 200
        except Exception as e:
            return jsonify({
                'message': 'error'
            }), 401

    ### 유저이름 얻는 ROUTER
    @app.route('/api/user/getUserName', methods=['GET'])
    def getUserName():

        user_id = request.args.get('user_id')

        from database_codes.database import getUserName

        try:
            user_name = getUserName(user_id)
            return jsonify({
                'user_name': user_name
            }), '200'
        except:
            return jsonify({
                'error': 'N'
            }), '404'

    ### 악보 삭제하는 ROUTER
    @app.route('/api/song/deleteScore', methods=['POST'])
    def deleteScoreFunc():
        deleteData = request.json

        song_part_id = deleteData['song_part_id']
        song_id = deleteData['song_id']

        from database_codes.database import deleteScore

        try:
            deleteScore(song_part_id, song_id)

            return jsonify({
                'status': 'success'
            }), '200'
        except:
            return jsonify({
                'status': 'fail'
            }), '404'

    ### 리뷰 삭제 ROUTER
    @app.route('/api/review/deleteReview', methods=['POST'])
    def deleteReview():
        deleteData = request.json

        user_id = deleteData['user_id']
        song_name = deleteData['song_name']
        song_part_id = deleteData['song_part_id']

        from database_codes.database import deleteReviewByUserId
        try:
            deleteReviewByUserId(user_id=user_id, song_part_id=song_part_id, song_name=song_name)
            return jsonify({
                'status': 'success'
            }), '200'
        except:
            return jsonify({
                'status': 'error'
            }), '404'

    return app


if __name__ == '__main__':
    from database_codes.database import makeUserTable, makeSongTable, makeSongPartTable, makeReviewTable

    # 초기 서버 실행 시 DB에 테이블 형성
    makeUserTable()
    makeSongTable()
    makeSongScoreTable()
    makeSongPartTable()
    makeReviewTable()

    app = create_app()
    app.run(host='0.0.0.0', port=5000)
