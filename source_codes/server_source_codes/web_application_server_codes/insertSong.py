"""
1. 음원 데이터를 10초 단위로 분리해서 저장한다.
2. 음악 데이터에 대한 정보를 입력한다.
3. 음원 데이터를 s3에 저장하고, 재생 주소를 반환해서 저장한다.
4. 모든 데이터를 데이터베이스에 저장한다.

"""
from database_codes.aws_s3_codes import upload_to_aws
from make_song_feature import divide_audio
from database_codes.database import insertSongTable


# 곡 DB에 삽입 및 AWS 삽입 함수
def insertSong(song_name, duration, composer, file_path):

    #업로드 간편화
    #song_name = 'bach'
    #composer = 'jungwook_' + composer
    #duration = 104


    song_segment_url_list = []
    s3_song_file_url_list = []
    print('==' * 50)
    print('곡 분할 시작..')

    print(file_path)
    divided_song_list = divide_audio(file_path)
    print('곡 분할 완료')
    print()

    print('==' * 50)
    print('AWS 업로드 시작..')
    for i in range(len(divided_song_list)):
        uploaded, file_url = upload_to_aws(divided_song_list[i], f'{composer}/segment_{i}.mp3')
        s3_song_file_url_list.append((file_url)) # url과 sequence 정보

    print('AWS 업로드 완료')
    from component_classes.component import Song

    song = Song(
        song_name=song_name,
        duration=duration,
        composer=composer,
        sequence=[i for i in range(len(s3_song_file_url_list))],
        url= s3_song_file_url_list
    )
    print()
    print('=='*50)
    print('DB에 Part 정보 삽입중..')

    song_id = insertSongTable(song)  #song_id 결정으로 수정 필요

    print('삽입 완료')
    return song_id

# 악보 DB에 삽입 및 AWS 삽입 함수
def insertScore(song_id, song_name, image_file_path_list, song_part_id):

    image_file_url = []
    sequence_url = [i for i in range(len(image_file_path_list))]

    print('==' * 50)
    print('악보 AWS 업로드 시작..')

    for i in range(len(image_file_path_list)):
        uploaded, file_url = upload_to_aws(image_file_path_list[i], f'{song_name}_{song_part_id}/img/img_{i}.png')
        image_file_url.append(file_url)

    print('AWS 업로드 완료')
    from database_codes.database import insertSongScoreTable
    print(f'image = {len(image_file_url)}')
    print()
    print('==' * 50)
    print('DB에 Part 정보 삽입중..')

    for i in range(len(image_file_url)):
        print('song_id=',song_id, 'score_sequence=',sequence_url[i], 'score_url=',image_file_url[i], 'song_part_id=',song_part_id)
        insertSongScoreTable(song_id=song_id, score_sequence=sequence_url[i], score_url=image_file_url[i], song_part_id=song_part_id)
    print('삽입 완료')


