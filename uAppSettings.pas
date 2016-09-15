unit uAppSettings;

interface

type
  TmyVKApp = record
    class function ID: string; static;
    class function Key: string; static;
    class function OAuthURL: string; static;
    class function RedirectURL: string; static;
    class function BaseURL: string; static;
    class function Scope: string; static;
    class function APIVersion: string; static;
  end;

implementation

{ TmyVKApp }

class function TmyVKApp.APIVersion: string;
begin
  Result := '5.53';
end;

class function TmyVKApp.BaseURL: string;
begin
  Result := 'https://api.vk.com/method/';
end;

class function TmyVKApp.ID: string;
begin
  Result := '5627868';
end;

class function TmyVKApp.Key: string;
begin
  Result := '5k7aL5MbVTkVevhqfQ9R';
end;

class function TmyVKApp.OAuthURL: string;
begin
  Result := 'https://oauth.vk.com/authorize';
end;

class function TmyVKApp.RedirectURL: string;
begin
  Result := '';
end;

class function TmyVKApp.Scope: string;
begin
  Result := 'wall,photos';
end;

end.
