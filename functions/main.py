# -*- coding: utf-8 -*-
# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`


from firebase_functions import https_fn, options, firestore_fn
from firebase_admin import initialize_app, firestore, credentials
import google.cloud.firestore
import os
import openai
from openai import OpenAI
import json
import firebase_admin

#client = OpenAI()
initialize_app()
os.getcwd() 

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
openai.api_key = OPENAI_API_KEY


# def my_chatbot():
#     response = client.chat.completions.create(
#     model="gpt-4-turbo",
#     messages=[
#       {"role": "system",
#       "content": """
#               너는 패션 전문가야. 주어진 사진에서 사람이 입은 옷의 색상, 종류, 가짓수를 모두 꼼꼼히 파악하고 옳은 카테고리를 찾아 분류해줘.

#               1. 사진 속 인물의 아우터를 [후드 집업, 블루종, MA-1, 레더 재킷, 라이더스 재킷, 무스탕, 퍼 재킷, 트러커 재킷, 슈트 재킷, 블레이저 재킷, 카디건, 아노락 재킷, 플리스, 뽀글이, 트레이닝 재킷, 스타디움 재킷, 환절기 코트, 겨울 싱글 코트, 겨울 더블 코트, 롱패딩, 롱헤비아우터, 숏패딩, 숏헤비아우터, 패딩 베스트, 베스트, 헌팅 재킷, 나일론 재킷, 코치 재킷] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 아우터를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아.
#               2. 사진 속 인물의 상의를 [맨투맨, 스웨트셔츠, 셔츠, 블라우스, 후드 티셔츠, 반소매 니트, 긴소매 니트, 스웨터, 카라티셔츠, 긴소매 티셔츠, 반소매 티셔츠, 민소매 티셔츠, 스포츠 상의, 미니 원피스, 미디 원피스, 맥시 원피스] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 상의를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아.
#               3. 사진 속 인물의 하의를 [데님 팬츠, 코튼 팬츠, 슈트 팬츠, 슬랙스, 트레이닝 팬츠, 조거 팬츠, 숏 팬츠, 레깅스, 점프 슈트, 오버올, 스포츠 하의, 미니스커트, 미디스커트, 롱스커트] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 하의를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아.
#               4. 사진 속 인물의 신발을 [스니커즈화, 캔버스, 단화, 구두, 로퍼, 힐, 펌프스, 플랫 슈즈, 블로퍼, 샌들, 슬리퍼, 모카신, 보트 슈즈, 부츠] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 신발을 신지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아.
#               5. 사진 속 인물이 착용한 가방을 [백팩, 크로스백, 숄더백, 토트백, 에코백, 더플백, 웨이스트 백, 파우치 백, 브리프케이스, 캐리어, 클러치 백] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 가방을 들지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아. 
#               6. 사진 속 인물이 착용한 모자를 [캡 모자, 야구 모자, 헌팅캡, 베레모, 페도라, 버킷햇, 비니, 트루퍼] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 모자를 쓰지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아.
#               7. 사진 속 인물이 입은 의상의 메인 컬러를 파악하고 유사한 css 색상 코드를 알려줘.
#               8. 사진 속 인물이 입은 의상 스타일을 [캐주얼, 포멀, 스마트 캐주얼, 비즈니스 캐주얼, 스포츠웨어, 빈티지, 보헤미안, 고스, 프레피, 미니멀, 로맨틱, 아방가르드] 중 가장 적합한 카테고리로 분류해서 알려줘. "color"와 "css_color" 값은 null로 지정해줘.


#               출력은 JSON 형태로 부탁할게! 예시는 다음과 같아. 

#               Created data: [{"main_category": "아우터", "sub_category": "후드 집업", "color": "인디고", "css_color": "#3C467D"}, {"main_category": "상의", "sub_category": "맨투맨", "color": "화이트", "css_color": "#FFFFFF"}, {"main_category": "하의", "sub_category": "조거 팬츠", "color": "블랙", "css_color": "#000000"}, {"main_category": "신발", "sub_category": null, "color": null, "css_color": null},  {"main_category": "가방", "sub_category": "에코백", "color": "블랙", "css_color": "#000000"}, {"main_category": "모자", "sub_category": null, "color": null, "css_color": null}, {"main_category": "메인 컬러", "sub_category": "메인 컬러", "color": "인디고", "css_color": "#3C467D"}, {"main_category": "스타일", "sub_category": "캐주얼", "color": null, "css_color": null}]
    
#           """},
#       {"role": "user", "content": [
#           {"type": "text", "text": """주어진 사진에서 사람이 입은 옷의 색상, 종류, 가짓수를 모두 꼼꼼히 파악하고 옳은 카테고리를 찾아 분류해서 JSON 형태로 정리해줘. Created data: [{"main_category": "아우터", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "상의", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "하의", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "신발", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "가방", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "모자", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "메인 컬러", "sub_category": "메인 컬러", "color": "", "css_color": ""}, {"main_category": "스타일", "sub_category": "", "color": null, "css_color": null} ]"""},
#           {
#             "type": "image_url",
#             "image_url": {
#                 "url": "https://m.uremind.co.kr/web/product/big/202302/3680bc505056ad936faa4e9af25d4dd8.jpg",
#             },
#             },
#         ],
#         }
#     ],
#     max_tokens=300,
#     )

#     print(response.choices[0].message.content)

#     # 챗봇이 생성된 텍스트 가져오기
#     # generated_text = response.choices[0].text
#     generated_text = json.loads(response.choices[0].message.content)

#     # 생성된 텍스트를 응답으로 반환
#     return generated_text


# #사진 업로드와 동시에 해당 함수 실행, 사진이랑 분석 데이터 저장하는 과정 진행되어야 함. 
# # @https_fn.on_request(
# #     cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]),
# #     region='asia-northeast3'
# # )
# # def my_chatbot(req: https_fn.Request) -> https_fn.Response:
# #     try:
# #         user_query= req.data.decode('utf-8') 
        
# #         response = client.chat.completions.create(
# #           model="gpt-4-turbo",
# #           response_format={"type": "json_object"},
# #           messages=[
# #               {"role": "system", 
# #               "content": """
# #                       너는 패션 전문가야. 주어진 사진에서 사람이 입은 옷의 색상, 종류, 가짓수를 모두 꼼꼼히 파악하고 옳은 카테고리를 찾아 분류해줘. 

# #                       1. 사진 속 인물의 아우터를 [후드 집업, 블루종/MA-1, 레더/라이더스 재킷, 무스탕/퍼, 트러커 재킷, 슈트/블레이저 재킷, 카디건, 아노락 재킷, 플리스/뽀글이, 트레이닝 재킷, 스타디움 재킷, 환절기 코트, 겨울 싱글 코트, 겨울 더블 코트, 롱패딩/롱헤비아우터, 숏패딩/숏헤비아우터, 패딩 베스트, 베스트, 사파리/헌팅 재킷, 나일론/코치 재킷] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 아우터를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아. 
# #                       2. 사진 속 인물의 상의를 [맨투맨/스웨트셔츠, 셔츠/블라우스, 후드 티셔츠, 니트/스웨터, 피케/카라티셔츠, 긴소매 티셔츠, 반소매 티셔츠, 민소매 티셔츠, 스포츠 상의, 미니 원피스, 미디 원피스, 맥시 원피스] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 상의를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아. 
# #                       3. 사진 속 인물의 하의를 [데님 팬츠, 코튼 팬츠, 슈트 팬츠/슬랙스, 트레이닝/조거 팬츠, 숏 팬츠, 레깅스, 점프 슈트/오버올, 스포츠 하의, 미니스커트, 미디스커트, 롱스커트] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 하의를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아. 
# #                       4. 사진 속 인물의 신발을 [스니커즈화, 캔버스/단화, 구두, 로퍼, 힐/펌프스, 플랫 슈즈, 블로퍼, 샌들, 슬리퍼, 모카신/보트 슈즈, 부츠] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 하의를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아. 

# #                       출력은 JSON 형태로 부탁할게! 예시는 다음과 같아. 

# #                         [{"main_category": "아우터", "sub_category": "후드 집업", "color": "indigo", "css_color": "#3C467D"}, {"main_category": "상의", "sub_category": "맨투맨", "color": "white", "css_color": "#FFFFFF"}, {"main_category": "하의", "sub_category": "조거 팬츠", "color": "black", "css_color": "#000000"}, {"main_category": "신발", "sub_category": null, "color": null, "css_color": null}]
    
# #                   """},
# #               {"role": "user", "content": [
# #                   {"type": "text", "text": """주어진 사진에서 사람이 입은 옷의 색상, 종류, 가짓수를 모두 꼼꼼히 파악하고 옳은 카테고리를 찾아 분류해서 JSON 형태로 정리해줘 : [{"main_category": "아우터", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "상의", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "하의", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "신발", "sub_category": "", "color": "", "css_color": ""}]"""},
# #                   {
# #                     "type": "image_url",
# #                     "image_url": {
# #                         "url": "https://m.uremind.co.kr/web/product/big/202302/3680bc505056ad936faa4e9af25d4dd8.jpg",
# #                     },
# #                   },
# #                 ],
# #               }
# #           ],
# #           max_tokens=300,
# #         )

# #         generated_text = response.choices[0].message.content

# #         #return https_fn.Response(generated_text)
        
# #         return https_fn.Response(generated_text)

# #     except Exception as e:
# #         return https_fn.Response(generated_text)
    

#여기 주석풀기
@https_fn.on_request(
    cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]),
    region='asia-northeast3'
)
def my_chatbot(req: https_fn.Request) -> https_fn.Response:
    try:
        url= req.data.decode('utf-8') 
        
        response = client.chat.completions.create(
          model="gpt-4-turbo",
          response_format={"type": "json_object"},
          messages=[
              {"role": "system", 
              "content": """
                      너는 패션 전문가야. 주어진 사진에서 사람이 입은 옷의 색상, 종류, 가짓수를 모두 꼼꼼히 파악하고 옳은 카테고리를 찾아 분류해줘. 

                    1. 사진 속 인물의 아우터를 [후드 집업, 블루종, MA-1, 레더 재킷, 라이더스 재킷, 무스탕, 퍼 재킷, 트러커 재킷, 슈트 재킷, 블레이저 재킷, 카디건, 아노락 재킷, 플리스, 뽀글이, 트레이닝 재킷, 스타디움 재킷, 환절기 코트, 겨울 싱글 코트, 겨울 더블 코트, 롱패딩, 롱헤비아우터, 숏패딩, 숏헤비아우터, 패딩 베스트, 베스트, 헌팅 재킷, 나일론 재킷, 코치 재킷] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 아우터를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아.
                    2. 사진 속 인물의 상의를 [맨투맨, 스웨트셔츠, 셔츠, 블라우스, 후드 티셔츠, 반소매 니트, 긴소매 니트, 스웨터, 카라티셔츠, 긴소매 티셔츠, 반소매 티셔츠, 민소매 티셔츠, 스포츠 상의, 미니 원피스, 미디 원피스, 맥시 원피스] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 상의를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아.
                    3. 사진 속 인물의 하의를 [데님 팬츠, 코튼 팬츠, 슈트 팬츠, 슬랙스, 트레이닝 팬츠, 조거 팬츠, 숏 팬츠, 레깅스, 점프 슈트, 오버올, 스포츠 하의, 미니스커트, 미디스커트, 롱스커트] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 하의를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아.
                    4. 사진 속 인물의 신발을 [스니커즈화, 캔버스, 단화, 구두, 로퍼, 힐, 펌프스, 플랫 슈즈, 블로퍼, 샌들, 슬리퍼, 모카신, 보트 슈즈, 부츠] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 신발을 신지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아.
                    5. 사진 속 인물이 착용한 가방을 [백팩, 크로스백, 숄더백, 토트백, 에코백, 더플백, 웨이스트 백, 파우치 백, 브리프케이스, 캐리어, 클러치 백] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 가방을 들지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아. 
                    6. 사진 속 인물이 착용한 모자를 [캡 모자, 야구 모자, 헌팅캡, 베레모, 페도라, 버킷햇, 비니, 트루퍼] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 모자를 쓰지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아.
                    7. 사진 속 인물의 입은 의상의 메인 컬러를 파악하고 유사한 css 색상 코드를 알려줘.
                    8. 사진 속 인물이 입은 의상 스타일을 [캐주얼, 포멀, 스마트 캐주얼, 비즈니스 캐주얼, 스포츠웨어, 빈티지, 보헤미안, 고스, 프레피, 미니멀, 로맨틱, 아방가르드] 중 가장 적합한 카테고리로 분류해서 알려줘. "color"와 "css_color" 값은 null로 지정해줘.


                    출력은 JSON 형태로 부탁할게! 예시는 다음과 같아. 

                    Created data: [{"main_category": "아우터", "sub_category": "후드 집업", "color": "인디고", "css_color": "#3C467D"}, {"main_category": "상의", "sub_category": "맨투맨", "color": "화이트", "css_color": "#FFFFFF"}, {"main_category": "하의", "sub_category": "조거 팬츠", "color": "블랙", "css_color": "#000000"}, {"main_category": "신발", "sub_category": null, "color": null, "css_color": null},  {"main_category": "가방", "sub_category": "에코백", "color": "블랙", "css_color": "#000000"}, {"main_category": "모자", "sub_category": null, "color": null, "css_color": null}, {"main_category": "메인 컬러", "sub_category": "메인 컬러", "color": "인디고", "css_color": "#3C467D"}, {"main_category": "스타일", "sub_category": "캐주얼", "color": null, "css_color": null}]
    
                  """},
              {"role": "user", "content": [
                  {"type": "text", "text": """주어진 사진에서 사람이 입은 옷의 색상, 종류, 가짓수를 모두 꼼꼼히 파악하고 옳은 카테고리를 찾아 분류해서 JSON 형태로 정리해줘. Created data: [{"main_category": "아우터", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "상의", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "하의", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "신발", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "가방", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "모자", "sub_category": "", "color": "", "css_color": ""}, {"main_category": "메인 컬러", "sub_category": "메인 컬러", "color": "", "css_color": ""}, {"main_category": "스타일", "sub_category": "", "color": null, "css_color": null} ]"""},
                  {
                    "type": "image_url",
                    "image_url": {
                        "url": url,
                    },
                  },
                ],
              }
          ],
          max_tokens=500,
        )

        generated_text = response.choices[0].message.content

        #return https_fn.Response(generated_text)
        
        return https_fn.Response(generated_text)

    except Exception as e:
        return https_fn.Response(generated_text)
    


#주석풀기
@https_fn.on_request(
    cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]),
    region='asia-northeast3'
)
def my_report(req: https_fn.Request) -> https_fn.Response:
    userdata = req.data.decode('utf-8')
    datalist = userdata.split()
    userName = datalist[0]
    useruid = datalist[1]
    # cred = credentials.Certificate("look-c1bf8-firebase-adminsdk-cgeh1-36688ca378.json")
    # firebase_admin.initialize_app(cred) 
        
    db = firestore.client()
    _outerName = ""
    _topName = ""
    _shoseName = ""
    _accName = ""
    
    marker_per_day = ""
    styles_per_day = ""
    keywords_per_day = ""
    
    
    
    try:
        # Firestore 쿼리 아우터 
        outer_ref = db.collection("closet_per_user").document(useruid).collection("아우터")
        query = outer_ref.order_by("wear_times", direction=firestore.Query.DESCENDING).limit(1)
        docs = query.stream()

        for doc in docs:
            if doc.exists:
                # 문서가 존재하는 경우
                document_data = doc.to_dict()
                _outerName = doc.id
                _outerimageLink = document_data['imagelink']
                _outertimes = document_data['wear_times']

                print(f"Outer Name: {_outerName}")
                #print(f"Image Link: {_accimageLink}")
                #print(f"Wear Times: {_acctimes}")
            else:
                print("No such document!")
        
        # Firestore 쿼리 상의
        top_ref = db.collection("closet_per_user").document(useruid).collection("상의")
        query = top_ref.order_by("wear_times", direction=firestore.Query.DESCENDING).limit(1)
        docs = query.stream()

        for doc in docs:
            if doc.exists:
                # 문서가 존재하는 경우
                document_data = doc.to_dict()
                _topName = doc.id
                _topimageLink = document_data['imagelink']
                _toptimes = document_data['wear_times']

                print(f"Top Name: {_topName}")
                #print(f"Image Link: {_accimageLink}")
                #print(f"Wear Times: {_acctimes}")
            else:
                print("No such document!")
        
        # Firestore 쿼리 하의
        bottom_ref = db.collection("closet_per_user").document(useruid).collection("하의")
        query = bottom_ref.order_by("wear_times", direction=firestore.Query.DESCENDING).limit(1)
        docs = query.stream()

        for doc in docs:
            if doc.exists:
                # 문서가 존재하는 경우
                document_data = doc.to_dict()
                _bottomName = doc.id
                _bottomimageLink = document_data['imagelink']
                _bottomtimes = document_data['wear_times']

                print(f"Bottom Name: {_bottomName}")
                #print(f"Image Link: {_accimageLink}")
                #print(f"Wear Times: {_acctimes}")
            else:
                print("No such document!")
        
        # Firestore 쿼리 신발 
        shose_ref = db.collection("closet_per_user").document(useruid).collection("하의")
        query = shose_ref.order_by("wear_times", direction=firestore.Query.DESCENDING).limit(1)
        docs = query.stream()

        for doc in docs:
            if doc.exists:
                # 문서가 존재하는 경우
                document_data = doc.to_dict()
                _shoseName = doc.id
                _shoseimageLink = document_data['imagelink']
                _shosetimes = document_data['wear_times']

                print(f"Shose Name: {_shoseName}")
                #print(f"Image Link: {_accimageLink}")
                #print(f"Wear Times: {_acctimes}")
            else:
                print("No such document!")
        
        
        # Firestore 쿼리 잡화
        collection_ref = db.collection("closet_per_user").document(useruid).collection("잡화")
        query = collection_ref.order_by("wear_times", direction=firestore.Query.DESCENDING).limit(1)
        docs = query.stream()

        for doc in docs:
            if doc.exists:
                # 문서가 존재하는 경우
                document_data = doc.to_dict()
                _accName = doc.id
                _accimageLink = document_data['imagelink']
                _acctimes = document_data['wear_times']

                print(f"Accessory Name: {_accName}")
                #print(f"Image Link: {_accimageLink}")
                #print(f"Wear Times: {_acctimes}")
            else:
                print("No such document!")
        
        # color_marker
        color_marker_ref = db.collection("report_per_user").document(useruid).collection("color_marker").document('2024.06')
        doc = color_marker_ref.get()

        if doc.exists:
            document_data = doc.to_dict()
            marker_per_day = document_data['color_marker']
            print(f"Color Marker: {marker_per_day}")
        else:
            print("No color_marker document!")
            
        #styles_per_day
        styles_ref = db.collection("report_per_user").document(useruid).collection("styles").document('2024.06')
        doc = styles_ref.get()

        if doc.exists:
            document_data = doc.to_dict()
            styles_per_day = document_data['styles']
            print(f"Styles: {styles_per_day}")
        else:
            print("No color_marker document!")
            
        #keyword_per_day
        keywords_ref = db.collection("report_per_user").document(useruid).collection("keywords").document('2024.06')
        doc = keywords_ref.get()

        if doc.exists:
            document_data = doc.to_dict()
            keywords_per_day = document_data['keywords']
            print(f"Styles: {keywords_per_day}")
        else:
            print("No color_marker document!")
        
        
        api_key = "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"
        client = OpenAI(api_key=api_key)
        response = client.chat.completions.create(
                model="gpt-4-turbo",
                messages=[
                    {"role": "system", "content": "너는 패션 전문가야. 사용자가 어플에 날마다 본인의 옷차람 사진을 업로드하면, 그걸 분석해서 월간 리포트를 작성하려고 해. 사용자 옷차람에 관련된 데이터를 제공하면, 사용자가 흥미를 느낄 수 있도록 친절한 말투와 이모티콘을 써서 월간 패션 분석 리포트를 작성해줘."},
                    {"role": "user", "content": 
                        f"""
                        너는 패션 전문가야. 사용자의 아래 월간 옷차림 데이터를 이용해서 사용자가 흥미를 느낄 수 있도록 친절한 말투와 이모티콘을 써서 월간 패션 분석 리포트를 작성해줘.
                        데이터는 총 3개고, 순서대로 {{날짜('연-월-일 시:분:초.밀리초' 형식) : 해당 날짜 옷차림의 메인 컬러 색상 코드}} 모음, {{날짜 : 해당 날짜의 패션 스타일}} 모음, {{날짜 : [해당 날짜에 사용자가 고른 옷차람 설명 키워드들]}} 모음, {{옷 카테고리: 해당 카테고리에서 이번달에 제일 많이 입은 옷}} 모음 이야.
                        리포트에는 이번달의 메인 컬러, 자주 입는 스타일, 제일 많이 입은 옷과 컬러를 기반으로 한 코디 추천 등을 포함해줘! 코디 추천에는 현재 한국의 계절감이나 날씨를 반영해줘! 사용자 이름은 {userName}이야!
                        색상 출력에는 다음처럼 앞에 **와 backquote를 추가해줘! e.g) **`#FFA500`
                        
                        1번 데이터 : {marker_per_day}
                        2번 데이터 : {styles_per_day}
                        3번 데이터 : {keywords_per_day}
                        4번 데이터 : {{아우터: {_outerName}, 상의: {_topName}, 하의: {_bottomName}, 신발: {_shoseName}, 잡화: {_accName}}}
                        
                    """
                    }
                ],
                max_tokens=1500,
            )
        
            #print(response.choices[0].message.content)
        generated_text = response.choices[0].message.content
        return https_fn.Response(generated_text)
                
    except Exception as e:
        print(f"An error occurred: {e}")
        return https_fn.Response(useruid)
    
    
        
#         generated_text = response.choices[0].message.content
#         print(generated_text)
#         return https_fn.Response(generated_text)
    
    
#     except Exception as e:
#         return https_fn.Response(useruid)



# def my_reportt(useruid):
#     cred = credentials.Certificate("look-c1bf8-firebase-adminsdk-cgeh1-36688ca378.json")
#     firebase_admin.initialize_app(cred) 
        
#     db = firestore.client()
#     _outerName = ""
#     _topName = ""
#     _shoseName = ""
#     _accName = ""
    
#     marker_per_day = ""
#     styles_per_day = ""
#     keywords_per_day = ""
    
    
    
#     try:
#         # Firestore 쿼리 아우터 
#         outer_ref = db.collection("closet_per_user").document(useruid).collection("아우터")
#         query = outer_ref.order_by("wear_times", direction=firestore.Query.DESCENDING).limit(1)
#         docs = query.stream()

#         for doc in docs:
#             if doc.exists:
#                 # 문서가 존재하는 경우
#                 document_data = doc.to_dict()
#                 _outerName = doc.id
#                 _outerimageLink = document_data['imagelink']
#                 _outertimes = document_data['wear_times']

#                 print(f"Outer Name: {_outerName}")
#                 #print(f"Image Link: {_accimageLink}")
#                 #print(f"Wear Times: {_acctimes}")
#             else:
#                 print("No such document!")
        
#         # Firestore 쿼리 상의
#         top_ref = db.collection("closet_per_user").document(useruid).collection("상의")
#         query = top_ref.order_by("wear_times", direction=firestore.Query.DESCENDING).limit(1)
#         docs = query.stream()

#         for doc in docs:
#             if doc.exists:
#                 # 문서가 존재하는 경우
#                 document_data = doc.to_dict()
#                 _topName = doc.id
#                 _topimageLink = document_data['imagelink']
#                 _toptimes = document_data['wear_times']

#                 print(f"Top Name: {_topName}")
#                 #print(f"Image Link: {_accimageLink}")
#                 #print(f"Wear Times: {_acctimes}")
#             else:
#                 print("No such document!")
        
#         # Firestore 쿼리 하의
#         bottom_ref = db.collection("closet_per_user").document(useruid).collection("하의")
#         query = bottom_ref.order_by("wear_times", direction=firestore.Query.DESCENDING).limit(1)
#         docs = query.stream()

#         for doc in docs:
#             if doc.exists:
#                 # 문서가 존재하는 경우
#                 document_data = doc.to_dict()
#                 _bottomName = doc.id
#                 _bottomimageLink = document_data['imagelink']
#                 _bottomtimes = document_data['wear_times']

#                 print(f"Bottom Name: {_bottomName}")
#                 #print(f"Image Link: {_accimageLink}")
#                 #print(f"Wear Times: {_acctimes}")
#             else:
#                 print("No such document!")
        
#         # Firestore 쿼리 신발 
#         shose_ref = db.collection("closet_per_user").document(useruid).collection("하의")
#         query = shose_ref.order_by("wear_times", direction=firestore.Query.DESCENDING).limit(1)
#         docs = query.stream()

#         for doc in docs:
#             if doc.exists:
#                 # 문서가 존재하는 경우
#                 document_data = doc.to_dict()
#                 _shoseName = doc.id
#                 _shoseimageLink = document_data['imagelink']
#                 _shosetimes = document_data['wear_times']

#                 print(f"Shose Name: {_shoseName}")
#                 #print(f"Image Link: {_accimageLink}")
#                 #print(f"Wear Times: {_acctimes}")
#             else:
#                 print("No such document!")
        
        
#         # Firestore 쿼리 잡화
#         collection_ref = db.collection("closet_per_user").document(useruid).collection("잡화")
#         query = collection_ref.order_by("wear_times", direction=firestore.Query.DESCENDING).limit(1)
#         docs = query.stream()

#         for doc in docs:
#             if doc.exists:
#                 # 문서가 존재하는 경우
#                 document_data = doc.to_dict()
#                 _accName = doc.id
#                 _accimageLink = document_data['imagelink']
#                 _acctimes = document_data['wear_times']

#                 print(f"Accessory Name: {_accName}")
#                 #print(f"Image Link: {_accimageLink}")
#                 #print(f"Wear Times: {_acctimes}")
#             else:
#                 print("No such document!")
        
#         # color_marker
#         color_marker_ref = db.collection("report_per_user").document(useruid).collection("color_marker").document('2024.06')
#         doc = color_marker_ref.get()

#         if doc.exists:
#             document_data = doc.to_dict()
#             marker_per_day = document_data['color_marker']
#             print(f"Color Marker: {marker_per_day}")
#         else:
#             print("No color_marker document!")
            
#         #styles_per_day
#         styles_ref = db.collection("report_per_user").document(useruid).collection("styles").document('2024.06')
#         doc = styles_ref.get()

#         if doc.exists:
#             document_data = doc.to_dict()
#             styles_per_day = document_data['styles']
#             print(f"Styles: {styles_per_day}")
#         else:
#             print("No color_marker document!")
            
#         #keyword_per_day
#         keywords_ref = db.collection("report_per_user").document(useruid).collection("keywords").document('2024.06')
#         doc = keywords_ref.get()

#         if doc.exists:
#             document_data = doc.to_dict()
#             keywords_per_day = document_data['keywords']
#             print(f"Styles: {keywords_per_day}")
#         else:
#             print("No color_marker document!")
                
#     except Exception as e:
#         print(f"An error occurred: {e}")
    
#     client = OpenAI(api_key=api_key)
#     response = client.chat.completions.create(
#             model="gpt-4-turbo",
#             messages=[
#                 {"role": "system", "content": "너는 패션 전문가야. 사용자가 어플에 날마다 본인의 옷차람 사진을 업로드하면, 그걸 분석해서 월간 리포트를 작성하려고 해. 사용자 옷차람에 관련된 데이터를 제공하면, 사용자가 흥미를 느낄 수 있도록 친절한 말투와 이모티콘을 써서 월간 패션 분석 리포트를 작성해줘."},
#                 {"role": "user", "content": 
#                     f"""
#                      너는 패션 전문가야. 사용자의 아래 월간 옷차림 데이터를 이용해서 사용자가 흥미를 느낄 수 있도록 친절한 말투와 이모티콘을 써서 월간 패션 분석 리포트를 작성해줘.
#                      데이터는 총 3개고, 순서대로 {{날짜('연-월-일 시:분:초.밀리초' 형식) : 해당 날짜 옷차림의 메인 컬러 색상 코드}} 모음, {{날짜 : 해당 날짜의 패션 스타일}} 모음, {{날짜 : [해당 날짜에 사용자가 고른 옷차람 설명 키워드들]}} 모음, {{옷 카테고리: 해당 카테고리에서 이번달에 제일 많이 입은 옷}} 모음 이야.
#                      리포트에는 이번달의 메인 컬러, 자주 입는 스타일, 제일 많이 입은 옷과 컬러를 기반으로 한 코디 추천 등을 포함해줘! 사용자 이름은 {useruid}이야!
                    
#                      1번 데이터 : {marker_per_day}
#                      2번 데이터 : {styles_per_day}
#                      3번 데이터 : {keywords_per_day}
#                      4번 데이터 : {{아우터: {_outerName}, 상의: {_topName}, 하의: {_bottomName}, 신발: {_shoseName}, 잡화: {_accName}}}
                    
#                  """
#                 }
#             ],
#             max_tokens=1000,
#         )
    
#     print(response.choices[0].message.content)
            
    
        
        

        
        # user_id = data.get('user_id')
        # main_colors = data.get('main_colors')
        # styles = data.get('styles')
        # keywords = data.get('keywords')
        # outer = data.get('outer')
        # top = data.get('top')
        # bottom = data.get('bottom')
        # shoes = data.get('shoes')
        # acc = data.get('acc')
        
        # https_fn.Response(json.dumps({'message': 'Report saved successfully'}, ensure_ascii=False), status=200, mimetype='application/json')

        
        #return https_fn.Response(json.dumps({'message': acc}, ensure_ascii=False), status=200, mimetype='application/json')
        
        #return https_fn.Response(data)
    
        # https_fn.Response(json.dumps({'message': 'Report saved successfully'}, ensure_ascii=False), status=200, mimetype='application/json')
        
        # response = client.chat.completions.create(
        #     model="gpt-4-turbo",
        #     messages=[
        #         {"role": "system", "content": data},
        #         {"role": "user", "content": 
        #             {"type": "text", "text" : "너는 패션 전문가야. 사용자가 어플에 날마다 본인의 옷차람 사진을 업로드하면, 그걸 분석해서 월간 리포트를 작성하려고 해. 사용자 옷차람에 관련된 데이터를 제공하면, 사용자가 흥미를 느낄 수 있도록 친절한 말투와 이모티콘을 써서 월간 패션 분석 리포트를 작성해줘."},
        #         }
        #     ],
        #     max_tokens=1000,
        # )

        # generated_text = response.choices[0].message.content
        # return https_fn.Response(generated_text)
                     # "text": """
                    # 너는 패션 전문가야. 사용자의 아래 월간 옷차림 데이터를 이용해서 사용자가 흥미를 느낄 수 있도록 친절한 말투와 이모티콘을 써서 월간 패션 분석 리포트를 작성해줘.
                    # 데이터는 총 3개고, 순서대로 {날짜('연-월-일 시:분:초.밀리초' 형식) : 해당 날짜 옷차림의 메인 컬러 색상 코드} 모음, {날짜 : 해당 날짜의 패션 스타일} 모음, {날짜 : [해당 날짜에 사용자가 고른 옷차람 설명 키워드들]} 모음, {옷 카테고리: 해당 카테고리에서 이번달에 제일 많이 입은 옷} 모음 이야.
                    # 리포트에는 이번달의 메인 컬러, 자주 입는 스타일, 제일 많이 입은 옷과 컬러를 기반으로 한 코디 추천 등을 포함해줘! 사용자 이름은 yobi0810이야!
                    
                    # 1번 데이터 : {2024-06-03 00:00:00.000: #FFA500, 2024-06-04 00:00:00.000: #000000, 2024-06-05 00:00:00.000: #FFA500, 2024-06-06 00:00:00.000: #000000, 2024-06-07 00:00:00.000: #0000FF, 2024-06-08 00:00:00.000: #F5F5DC, 2024-06-09 00:00:00.000: #F5F5DC}
                    # 2번 데이터 : {2024-06-03 00:00:00.000: 캐주얼, 2024-06-04 00:00:00.000: 비즈니스 캐주얼, 2024-06-05 00:00:00.000: 캐주얼, 2024-06-06 00:00:00.000: 프레피, 2024-06-07 00:00:00.000: 캐주얼, 2024-06-08 00:00:00.000: 캐주얼, 2024-06-09 00:00:00.000: 캐주얼}
                    # 3번 데이터 : {2024-06-03 00:00:00.000: [✨ 화려해요], 2024-06-04 00:00:00.000: [😀 편해요, ✨ 화려해요], 2024-06-05 00:00:00.000: [👍 색조합 good], 2024-06-06 00:00:00.000: null, 2024-06-07 00:00:00.000: [😀 편해요, 👍 색조합 good], 2024-06-08 00:00:00.000: [😀 편해요], 2024-06-09 00:00:00.000: [😀 편해요]}
                    # 4번 데이터 : {아우터: 베이지 겨울 싱글 코트, 상의: 화이트 긴소매 티셔츠, 하의: 블랙 슬랙스, 신발: 화이트 스니커즈, 잡화: 블랙 토트백}
                    
                    # """},
                # "text": """
                #     너는 패션 전문가야. 사용자의 아래 월간 옷차림 데이터를 이용해서 사용자가 흥미를 느낄 수 있도록 친절한 말투와 이모티콘을 써서 월간 패션 분석 리포트를 작성해줘.
                #     데이터는 총 3개고, 순서대로 {날짜('연-월-일 시:분:초.밀리초' 형식) : 해당 날짜 옷차림의 메인 컬러 색상 코드} 모음, {날짜 : 해당 날짜의 패션 스타일} 모음, {날짜 : [해당 날짜에 사용자가 고른 옷차람 설명 키워드들]} 모음, {옷 카테고리: 해당 카테고리에서 이번달에 제일 많이 입은 옷} 모음 이야.
                #     리포트에는 이번달의 메인 컬러, 자주 입는 스타일, 제일 많이 입은 옷과 컬러를 기반으로 한 코디 추천 등을 포함해줘! 사용자 이름은 %s이야!
                    
                #     1번 데이터 : %s
                #     2번 데이터 : %s
                #     3번 데이터 : %s
                #     4번 데이터 : {아우터: %s, 상의: %s, 하의: %s, 신발: %s, 잡화: %s}
                    
                # """ %(user_id, main_colors, styles, keywords, outer, top, bottom, shoes, acc)},
                
            
    
    # except Exception as e:
    #     return https_fn.Response(data)


#
#
# @https_fn.on_request()
# def on_request_example(req: https_fn.Request) -> https_fn.Response:
#     return https_fn.Response("Hello world!")


# from openai import OpenAI

# client = OpenAI()

# response = client.chat.completions.create(
#   model="gpt-4-turbo",
#   messages=[
#     {"role": "system", "content": "너는 의류 전문가야."},
#     {"role": "user", "content": [
#         {"type": "text", 
#          "text": """
#             너는 패션 전문가야. 주어진 사진에서 사람이 입은 옷의 색상, 종류, 가짓수를 모두 꼼꼼히 파악하고 옳은 카테고리를 찾아 분류해줘. 

#               1. 사진 속 인물의 아우터를 [후드 집업, 블루종/MA-1, 레더/라이더스 재킷, 무스탕/퍼, 트러커 재킷, 슈트/블레이저 재킷, 카디건, 아노락 재킷, 플리스/뽀글이, 트레이닝 재킷, 스타디움 재킷, 환절기 코트, 겨울 싱글 코트, 겨울 더블 코트, 롱패딩/롱헤비아우터, 숏패딩/숏헤비아우터, 패딩 베스트, 베스트, 사파리/헌팅 재킷, 나일론/코치 재킷] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 아우터를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아. 
#               2. 사진 속 인물의 상의를 [맨투맨/스웨트셔츠, 셔츠/블라우스, 후드 티셔츠, 니트/스웨터, 피케/카라티셔츠, 긴소매 티셔츠, 반소매 티셔츠, 민소매 티셔츠, 스포츠 상의, 미니 원피스, 미디 원피스, 맥시 원피스] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 상의를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아. 
#               3. 사진 속 인물의 하의를 [데님 팬츠, 코튼 팬츠, 슈트 팬츠/슬랙스, 트레이닝/조거 팬츠, 숏 팬츠, 레깅스, 점프 슈트/오버올, 스포츠 하의, 미니스커트, 미디스커트, 롱스커트] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 하의를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아. 
#               4. 사진 속 인물의 신발을 [스니커즈화, 캔버스/단화, 구두, 로퍼, 힐/펌프스, 플랫 슈즈, 블로퍼, 샌들, 슬리퍼, 모카신/보트 슈즈, 부츠] 중 가장 적합한 카테고리로 분류하고 유사한 css 색상 코드를 알려줘. 모델이 하의를 입지 않았거나 사진에서 보이지 않는다면 알려주지 않아도 괜찮아. 

#               출력은 json 형태로 부탁할게! 예시는 다음과 같아. 

#               “OOTD": [

#               {”main_category": "아우터", "sub_category": "후드 집업", ”color": ”indigo”, "css_color": “#3C467D” },

#               {”main_category": "상의", "sub_category": "맨투맨", ”color": ”white”, "css_color": “#FFFFFF” },

#               {”main_category": "하의", "sub_category": "조거 팬츠", ”color": ”black”, "css_color": “#000000” },

#               {”main_category": "신발", "sub_category": null, ”color": null, "css_color": null }

#               ]
#           """},

#         {
#           "type": "image_url",
#           "image_url": {
#             "url": "https://m.uremind.co.kr/web/product/big/202302/3680bc505056ad936faa4e9af25d4dd8.jpg",
#           },
#         },
#       ],
#     }
#   ],
#   max_tokens=300,
# )

# print(response.choices[0].message.content)