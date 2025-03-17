from werkzeug.security import generate_password_hash

class User:

    def __init__(self, user_id, user_pwd, user_name, department, job, university, ph_num, created_date, modified_date):
        self.user_id = user_id
        self.user_pwd = generate_password_hash(user_pwd)
        self.user_name = user_name
        self.department = department
        self.job = job
        self.university = university
        self.ph_num = ph_num
        self.created_date = created_date
        self.modified_date = modified_date

    def getInfo(self):
        return [self.user_id, self.user_pwd, self.user_name, self.department, self.job, self.university, self.ph_num, self.created_date, self.modified_date]

    def getUserId(self):
        return self.user_id

    def getUserPassword(self):
        return self.user_pwd


class Song:

    def __init__(self, song_name, duration, composer, sequence, url):
        self.song_name = song_name
        self.duration = duration
        self.composer = composer
        self.sequence = sequence
        self.url = url

    def getSongData(self):
        return {
            'song_name' : self.song_name,
            'duration' : self.duration,
            'composer' : self.composer,
            'sequence' : self.sequence,
            'url' : self.url
        }

class Review:

    def __init__(self, user_id, song_id, song_part_seq,tone_score, legato_score, representation_score, phrasing_score, melody_score, music_score, voicing_score, note_score, dynamic_score, dynamic_change_score, tempo_score, tempo_change_score, articulation_score, rhythm_score, pedal_score):
        self.user_id = user_id
        self.song_id = song_id
        self.song_part_seq = song_part_seq
        self.tone_score = tone_score
        self.legato_score = legato_score
        self.representation_score = representation_score
        self.phrasing_score = phrasing_score
        self.melody_score = melody_score
        self.music_score = music_score
        self.voicing_score = voicing_score
        self.note_score = note_score
        self.dynamic_score = dynamic_score
        self.dynamic_change_score = dynamic_change_score
        self.tempo_score = tempo_score
        self.tempo_change_score =tempo_change_score
        self.articulation_score = articulation_score
        self.rhythm_score = rhythm_score
        self.pedal_score = pedal_score

    def getReviewData(self):

        return {
            'song_id' : self.song_id,
            'user_id' : self.user_id,
            'song_part_seq' : self.song_part_seq,
            'tone_score' : self.tone_score,
            'legato_score' : self.legato_score,
            'representation_score' :self.representation_score,
            'phrasing_score' : self.phrasing_score,
            'melody_score' : self.melody_score,
            'music_score' : self.music_score,
            'voicing_score' : self.voicing_score,
            'note_score' : self.note_score,
            'dynamic_score' : self.dynamic_score,
            'dynamic_change_score' : self.dynamic_change_score,
            'tempo_score' : self.tempo_score,
            'tempo_change_score' : self.tempo_change_score,
            'articulation_score' : self.articulation_score,
            'rhythm_score' : self.rhythm_score,
            'pedal_score' : self.pedal_score
        }
    def getReviewDataList(self):
        return [self.user_id,self.song_id, self.song_part_seq, self.tone_score, self.legato_score, self.representation_score, self.phrasing_score,
         self.melody_score, self.music_score, self.voicing_score, self.note_score, self.dynamic_score, self.dynamic_change_score, self.tempo_score, self.tempo_change_score, self.articulation_score,
         self.rhythm_score, self.pedal_score]