from werkzeug.security import check_password_hash
import sys
from database_codes.database import getUserPassword


def _login(user_id, user_password):
    """
    login 요청하기
    :return:
        0 - 로그인 성공
        1 - 로그인 실패


        jungwook
    """

    # 1. 데이터베이스에서 사용자에 대한 비밀번호 값 조회하기.
    db_User_password = getUserPassword(user_id)

    # 2. 불러 온 비밀번호와 사용자 비밀번호 값이 같은지 확인하기.
    print(db_User_password)
    print(user_password)
    print(user_id)
    if check_password_hash(db_User_password, user_password):
        return 0
    else:
        return 1


