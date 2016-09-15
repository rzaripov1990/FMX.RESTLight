unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ScrollBox, FMX.Memo,
  FMX.Controls.Presentation, FMX.StdCtrls
{$IFDEF MSWINDOWS}
    , REST.Authenticator.OAuth.WebForm.Win
{$ELSE}
    , REST.Authenticator.OAuth.WebForm.FMX
{$ENDIF}
    , FMX.RESTLight.Types, FMX.RESTLight;

type
  TfrmMain = class(TForm)
    btnAuth: TButton;
    btnWallMsg: TButton;
    Memo1: TMemo;
    btnAccOffline: TButton;
    btnWallPicture: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAuthClick(Sender: TObject);
    procedure btnWallMsgClick(Sender: TObject);
    procedure btnAccOfflineClick(Sender: TObject);
    procedure btnWallPictureClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AfterRedirect(const AURL: string; var DoCloseWebView: Boolean);
  end;

var
  frmMain: TfrmMain;
  WebForm: Tfrm_OAuthWebForm;

  FAuthToken: TmyAuthToken;
  FVKApp: TmyAppSettings;

implementation

{$R *.fmx}

uses
  System.DateUtils, System.Threading, System.IOUtils, XSuperObject, uAppSettings;

{ TfrmMain }

procedure TfrmMain.AfterRedirect(const AURL: string; var DoCloseWebView: Boolean);
var
  iPos: Integer;
  aStr: string;
  aParams: TStringList;
begin
  iPos := Pos('#access_token=', AURL);
  if (iPos > 0) and (FAuthToken.token.IsEmpty) then
  begin
    aStr := AURL;
    Delete(aStr, 1, iPos);
    aParams := TStringList.Create;
    try
      aParams.Delimiter := '&';
      aParams.DelimitedText := aStr;
      FAuthToken.token := aParams.Values['access_token'];
      FAuthToken.expires_in := IncSecond(Now, StrToInt(aParams.Values['expires_in']) - 10);
      FAuthToken.user_id := aParams.Values['user_id'];
    finally
      aParams.Free;
    end;
    DoCloseWebView := true;

    Memo1.Lines.Add('---- auth ----');
    Memo1.Lines.Add('token = ' + FAuthToken.token);
    Memo1.Lines.Add('owner_id = ' + FAuthToken.user_id);

    btnAuth.Enabled := false;
    btnWallMsg.Enabled := true;
    btnAccOffline.Enabled := true;
    btnWallPicture.Enabled := true;
  end;
end;

procedure TfrmMain.btnAccOfflineClick(Sender: TObject);
var
  aFields: TArray<TmyRestParam>;
  aJSON: string;
begin
  SetLength(aFields, 3);

  aFields[0] := TmyRestParam.Create('access_token', FAuthToken.token, false);
  aFields[1] := TmyRestParam.Create('v', FVKApp.APIVersion, false);
  aFields[2] := TmyRestParam.Create('owner_id', FAuthToken.user_id, false);

  TTask.Run(
    procedure
    begin
      aJSON := TRESTLight.Execute('account.setOffline', FVKApp, aFields);

      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          Memo1.Lines.Add('---- account.setOffline ----');
          Memo1.Lines.Add(aJSON);
        end);
    end);
end;

procedure TfrmMain.btnAuthClick(Sender: TObject);
begin
  FVKApp.ID := TmyVKApp.ID;
  FVKApp.Key := TmyVKApp.Key;
  FVKApp.OAuthURL := TmyVKApp.OAuthURL;
  FVKApp.RedirectURL := TmyVKApp.RedirectURL;
  FVKApp.BaseURL := TmyVKApp.BaseURL;
  FVKApp.Scope := TmyVKApp.Scope;
  FVKApp.APIVersion := TmyVKApp.APIVersion;

  WebForm.ShowWithURL(TRESTLight.AccessTokenURL(FVKApp));
end;

procedure TfrmMain.btnWallMsgClick(Sender: TObject);
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
end;

procedure TfrmMain.btnWallPictureClick(Sender: TObject);
var
  aFields: TArray<TmyRestParam>;
  aJSON: string;
  xJS: ISuperObject;

  aUploadURL: string;
  aAlbumID: string;

  aUploadFile: string;

  aPhotoServer: string;
  aPhotoData: string;
  aPhotoHash: string;

  aPhotoID: string;
begin
  aUploadURL := '';
  aAlbumID := '';

  aUploadFile := TPath.Combine(
{$IFDEF MSWINDOWS}
  TPath.GetDirectoryName(ParamStr(0)) + '\..\..\'
{$ELSE}
  TPath.GetDocumentsPath{$ENDIF}, 'fmx.jpg');

  if not FileExists(aUploadFile) then
  begin
    Memo1.Lines.Add('File not found');
    exit;
  end;

  SetLength(aFields, 3);
  aFields[0] := TmyRestParam.Create('access_token', FAuthToken.token, false);
  aFields[1] := TmyRestParam.Create('v', FVKApp.APIVersion, false);
  aFields[2] := TmyRestParam.Create('owner_id', FAuthToken.user_id, false);

  TTask.Run(
    procedure
    begin
      // photos.getWallUploadServer
      aJSON := TRESTLight.Execute('photos.getWallUploadServer', FVKApp, aFields);

      Log.d('---------------------- photos.getWallUploadServer');
      Log.d(aJSON);

      xJS := SO(aJSON);
      if xJS.Check('response') then
      begin
        aUploadURL := xJS.O['response'].S['upload_url'].Replace('\', '');
        aAlbumID := xJS.O['response'].I['album_id'].ToString;
      end;
      // ... photos.getWallUploadServer

      if (not aUploadURL.IsEmpty) and (not aAlbumID.IsEmpty) then
      begin
        // upload file to server
        aPhotoServer := '';
        aPhotoData := '';
        aPhotoHash := '';

        SetLength(aFields, 4);
        aFields[0] := TmyRestParam.Create('access_token', FAuthToken.token, false);
        aFields[1] := TmyRestParam.Create('v', FVKApp.APIVersion, false);
        aFields[2] := TmyRestParam.Create('owner_id', FAuthToken.user_id, false);
        aFields[3] := TmyRestParam.Create('photo', aUploadFile, true);

        aJSON := TRESTLight.Execute2(aUploadURL, FVKApp, aFields);

        Log.d('---------------------- upload file to server');
        Log.d(aJSON);

        xJS := SO(aJSON);
        if xJS.Check('server') then
        begin
          aPhotoServer := xJS.I['server'].ToString;
          aPhotoHash := xJS.S['hash'];
          aPhotoData := xJS.S['photo'];
        end;
        // ... upload file to server

        if (not aPhotoServer.IsEmpty) and (not aPhotoData.IsEmpty) and (not aPhotoHash.IsEmpty) then
        begin
          // photos.saveWallPhoto
          SetLength(aFields, 6);
          aFields[0] := TmyRestParam.Create('access_token', FAuthToken.token, false);
          aFields[1] := TmyRestParam.Create('v', FVKApp.APIVersion, false);
          aFields[2] := TmyRestParam.Create('user_id', FAuthToken.user_id, false);
          aFields[3] := TmyRestParam.Create('photo', aPhotoData, false);
          aFields[4] := TmyRestParam.Create('server', aPhotoServer, false);
          aFields[5] := TmyRestParam.Create('hash', aPhotoHash, false);

          aJSON := TRESTLight.Execute('photos.saveWallPhoto', FVKApp, aFields);

          Log.d('---------------------- photos.saveWallPhoto');
          Log.d(aJSON);

          xJS := SO(aJSON);
          if xJS.Check('response') then
          begin
            aPhotoID := xJS.A['response'].O[0].I['id'].ToString;
            aAlbumID := xJS.A['response'].O[0].I['album_id'].ToString;
          end;
          // ... photos.saveWallPhoto

          if (not aPhotoID.IsEmpty) and (not aAlbumID.IsEmpty) then
          begin
            // wall.post
            SetLength(aFields, 6);
            aFields[0] := TmyRestParam.Create('access_token', FAuthToken.token, false);
            aFields[1] := TmyRestParam.Create('v', FVKApp.APIVersion, false);
            aFields[2] := TmyRestParam.Create('owner_id', FAuthToken.user_id, false);
            aFields[3] := TmyRestParam.Create('friends_only', '1', false);
            aFields[4] := TmyRestParam.Create('message', 'Тестовое сообщение <RESTLight>', false);
            aFields[5] := TmyRestParam.Create('attachments', 'photo' + FAuthToken.user_id + '_' +
              aPhotoID + ',http://fire-monkey.ru', false);

            aJSON := TRESTLight.Execute('wall.post', FVKApp, aFields);

            Log.d('---------------------- wall.post');
            Log.d(aJSON);
            // .. wall.post
          end;
        end;

      end;

      TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin
          Memo1.Lines.Add('---- wall.post ----');
          Memo1.Lines.Add(aJSON);
        end);
    end);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  WebForm := Tfrm_OAuthWebForm.Create(nil);
  WebForm.OnAfterRedirect := AfterRedirect;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(WebForm);
end;

end.
