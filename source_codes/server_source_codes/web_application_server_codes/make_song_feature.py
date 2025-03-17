"""
음원 분리 코드
"""
import librosa
from pydub import AudioSegment
from math import ceil
from sound_to_midi.monophonic import wave_to_midi


divide_file_url_list = []


## 오디오 나누는 함수
def divide_audio(file_path, segment_duration=10000):
    """
    오디오 파일을 지정된 길이의 세그먼트로 분할하는 함수입니다.

    :param file_path: 분할할 오디오 파일의 경로입니다.
    :param segment_duration: 분할할 세그먼트의 길이입니다(밀리초 단위).
    """
    # 오디오 파일을 불러옵니다.
    audio = AudioSegment.from_file(file_path)

    # 전체 오디오 길이를 계산합니다.
    total_duration = len(audio)

    # 필요한 세그먼트의 수를 계산합니다.
    total_segments = ceil(total_duration / segment_duration)

    for i in range(total_segments):
        # 세그먼트를 추출합니다.
        start_time = i * segment_duration
        end_time = min((i + 1) * segment_duration, total_duration)
        segment = audio[start_time:end_time]

        # 세그먼트를 파일로 저장합니다.
        segment.export(f"test_song/segments/segment_{i + 1}.mp3", format="mp3")
        divide_file_url_list.append(f"test_song/segments/segment_{i + 1}.mp3")
    return divide_file_url_list

## 오디오 확장자 -> midi 파일로 함수
def audio_to_midi(audio_file_path, save_file_path):
    y, sr = librosa.load(audio_file_path, sr=None)
    midi = wave_to_midi(y, srate=int(sr))
    with open(save_file_path, 'wb') as f:
        midi.writeFile(f)


