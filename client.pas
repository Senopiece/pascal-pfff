//
// CLIENT v1.0
//

program client;
uses System.Net, System.Net.Sockets, System.Text;

begin
  try
    var clnt := new TcpClient('127.0.0.1', 4156);
    clnt.NoDelay := true;
    
    var stream := clnt.GetStream();
    
    var str_buff : array of byte;
    SetLength(str_buff, 256);
    
    while true do
    begin
      if stream.dataAvailable then
      begin
        var readed := stream.Read(str_buff, 0, str_buff.Length);
        var str := Encoding.UTF8.GetString(str_buff, 0, readed);
        
        case str[str.Length] of
          #2: 
          begin
            write(str[1:str.Length]);
          
            var input : string;
            readln(input);
          
            var input_buff := Encoding.UTF8.GetBytes(input + #3);
            stream.Write(input_buff, 0, Length(input_buff));
          end;
          
          #4:
          begin
            write(str[1:str.Length]);
            break;
          end;
          
          else write(str);
        end;
      end;
    end;
    
    stream.close();
    clnt.close();
    
  except on E: Exception do 
    writeln(E.Message);
  
  end;
end.