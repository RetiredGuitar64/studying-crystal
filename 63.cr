require "json"

body = <<-HEREDOC
{"code":2000000,"data":[{"id":"957163d40dd5487ea6d6a0525e5b553f","name":"testcourse2","type":"Theory","typeTitle":"理论","startTime":1775059200000,"endTime":1806681599000,"creator":"u648863899","orgId":"af9d27f9a71f4d1ba2e28cc1ed821b2f","icon":"https://staticfile.eduplus.net/default/resourceTheoryDefault4.png","term":"2025-2026第一学期","videoDrag":true,"publicStatus":"PRIVATE","publicStatusTitle":"未开放","focus":false,"teachClasses":[{"createAt":1775229931033,"updateAt":1775229931033,"createBy":"57b84f33c6b847aba7ef962e35240a3d","updateBy":"57b84f33c6b847aba7ef962e35240a3d","id":"ce85fa61840246a1ae95d6596fce1f32","name":"24130431class","courseId":"957163d40dd5487ea6d6a0525e5b553f","code":"PU71W9","homeworkWeightChange":"No","homeworkWeightChangeTitle":"否","experimentWeightChange":"No","experimentWeightChangeTitle":"否","teacherTeachClassModels":[]}],"leader":false,"courseSignInOpen":true,"courseSignInId":"3a5d8e974382400a869f63a4c01ee60c"},{"id":"583191e440774efda3f269055ef06a72","name":"testcourse","type":"Theory","typeTitle":"理论","startTime":1774972800000,"endTime":1806595199000,"creator":"u648863899","orgId":"af9d27f9a71f4d1ba2e28cc1ed821b2f","icon":"https://staticfile.eduplus.net/default/resourceTheoryDefault3.png","term":"2025-2026第一学期","videoDrag":true,"publicStatus":"PRIVATE","publicStatusTitle":"未开放","focus":false,"teachClasses":[{"createAt":1775210370885,"updateAt":1775210370885,"createBy":"57b84f33c6b847aba7ef962e35240a3d","updateBy":"57b84f33c6b847aba7ef962e35240a3d","id":"a6c001dade25409ba4b4c313c7cb1e1f","name":"默认班级","courseId":"583191e440774efda3f269055ef06a72","code":"61PPAK","homeworkWeightChange":"No","homeworkWeightChangeTitle":"否","experimentWeightChange":"No","experimentWeightChangeTitle":"否","teacherTeachClassModels":[]}],"leader":false,"courseSignInOpen":false}],"success":true,"tracer":"a2e8c0b365b679ef76cb1284eb2cf331","message":"OK","status":200}
HEREDOC

json = JSON.parse(body)

courses = json["data"]#.as_a
puts courses[0]
puts typeof(courses)
