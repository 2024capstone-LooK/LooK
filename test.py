import json

text = """
    [
        {"main_category": "아우터", "sub_category": "후드 집업", "color": "indigo", "css_color": "#3C467D"},
        {"main_category": "상의", "sub_category": "맨투맨", "color": "white", "css_color": "#FFFFFF"},
        {"main_category": "하의", "sub_category": "조거 팬츠", "color": "black", "css_color": "#000000"},
        {"main_category": "신발", "sub_category": null, "color": null, "css_color": null}
    ]
    """

print(json.loads(text))
