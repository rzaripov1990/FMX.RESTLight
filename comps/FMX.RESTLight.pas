unit FMX.RESTLight;

{
  author: ZuBy
  http://rzaripov.kz
  2016
}

interface

uses
  System.Types, System.SysUtils, System.Classes,
  System.Net.HTTPClient, System.Net.HTTPClientComponent,
  System.Net.URLClient, System.Net.Mime,
  FMX.RESTLight.Types;

type
  TRESTLight = record
    class function AccessTokenURL(const aAppSettings: TmyAppSettings): string; static;
    class function Execute(const aMethod: string; const aAppSettings: TmyAppSettings;
      const aFields: TArray<TmyRestParam>): string; static;
    class function Execute2(const ARequestURL: string; const aAppSettings: TmyAppSettings;
      const aFields: TArray<TmyRestParam>): string; static;
  end;

implementation

{ TRESTLight }

class function TRESTLight.AccessTokenURL(const aAppSettings: TmyAppSettings): string;
begin
  Result := aAppSettings.OAuthURL;
  Result := Result + '?response_type=' + TURI.URLEncode('token');
  if aAppSettings.ID <> '' then
    Result := Result + '&client_id=' + TURI.URLEncode(aAppSettings.ID);
  if aAppSettings.RedirectURL <> '' then
    Result := Result + '&redirect_uri=' + TURI.URLEncode(aAppSettings.RedirectURL);
  if aAppSettings.Scope <> '' then
    Result := Result + '&scope=' + TURI.URLEncode(aAppSettings.Scope);
end;

class function TRESTLight.Execute(const aMethod: string; const aAppSettings: TmyAppSettings;
  const aFields: TArray<TmyRestParam>): string;
var
  AHttp: TNetHTTPClient;
  AData: TMultipartFormData;
  AResp: IHTTPResponse;
  I: Integer;
begin
  Result := '';
  AHttp := TNetHTTPClient.Create(nil);
  try
    AData := TMultipartFormData.Create();
    try

      for I := Low(aFields) to High(aFields) do
      begin
        if aFields[I].is_file then
          AData.AddFile(aFields[I].Key, aFields[I].value)
        else
          AData.AddField(aFields[I].Key, aFields[I].value);
      end;

      AResp := AHttp.Post(aAppSettings.BaseURL + aMethod, AData);
      Result := AResp.ContentAsString();

    finally
      FreeAndNil(AData);
    end;
  finally
    FreeAndNil(AHttp);
  end;
end;

class function TRESTLight.Execute2(const ARequestURL: string; const aAppSettings: TmyAppSettings;
  const aFields: TArray<TmyRestParam>): string;
var
  AHttp: TNetHTTPClient;
  AData: TMultipartFormData;
  AResp: IHTTPResponse;
  I: Integer;
begin
  Result := '';
  AHttp := TNetHTTPClient.Create(nil);
  try
    AData := TMultipartFormData.Create();
    try

      for I := Low(aFields) to High(aFields) do
      begin
        if aFields[I].is_file then
          AData.AddFile(aFields[I].Key, aFields[I].value)
        else
          AData.AddField(aFields[I].Key, aFields[I].value);
      end;

      AResp := AHttp.Post(ARequestURL, AData);
      Result := AResp.ContentAsString();

    finally
      FreeAndNil(AData);
    end;
  finally
    FreeAndNil(AHttp);
  end;
end;

end.
