# TRESTLight

 * **uAppSettings.pas** - хранит описание вашего приложения [созданного в ВК](https://vk.com/dev) 
 * **FMX.RESTLight.pas** - модуль "общения" клиента с сервером
 * **FMX.RESTLight.Types.pas** - тут хранятся типы для работы TRESTLight
 
###### код постит текст на стену
```
var
  aFields: TArray<TmyRestParam>;
  aJSON: string;
begin
  SetLength(aFields, 5);

  aFields[0] := TmyRestParam.Create('access_token', FAuthToken.token, false);
  aFields[1] := TmyRestParam.Create('v', FVKApp.APIVersion, false);
  aFields[2] := TmyRestParam.Create('owner_id', FAuthToken.user_id, false);
  aFields[3] := TmyRestParam.Create('friends_only', '0', false);
  aFields[4] := TmyRestParam.Create('message', 'Тестовое сообщение <RESTLight>', false);

  TTask.Run(
    procedure
    begin
      aJSON := TRESTLight.Execute('wall.post', FVKApp, aFields);

      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          Memo1.Lines.Add('---- wall.post ----');
          Memo1.Lines.Add(aJSON);
        end);
    end);
```
###### отправка файлов на сервер
```
var
  aFields: TArray<TmyRestParam>;
  aJSON: string;
begin
   SetLength(aFields, 4);
   aFields[0] := TmyRestParam.Create('access_token', FAuthToken.token, false);
   aFields[1] := TmyRestParam.Create('v', FVKApp.APIVersion, false);
   aFields[2] := TmyRestParam.Create('owner_id', FAuthToken.user_id, false);
   aFields[3] := TmyRestParam.Create('photo', aUploadFile, true); // для файлов указывается !!!true!!!
	
  TTask.Run(
    procedure
    begin
      // для загрузки файлов использовать TRESTLight.Execute2, в нем можно указать произвольный URL 
	aJSON := TRESTLight.Execute2(aUploadURL, FVKApp, aFields);

      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          Memo1.Lines.Add('---- upload file to server ----');
          Memo1.Lines.Add(aJSON);
        end);
    end);
```
