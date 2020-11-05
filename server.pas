//
// SERVER v1.0(SINGLE-THREADED)
//

program server;
uses System.Net, System.Net.Sockets, System.Text;

var stream: NetworkStream;

procedure send(str: string); 
begin
  var buff := Encoding.UTF8.GetBytes(str);
  stream.Write(buff, 0, Length(buff));
end;

procedure sendln(str: string);
begin
  send(str + #10);
end;

function recieve() : string;
begin
  stream.WriteByte(2);
  
  var buff : array of byte;
  SetLength(buff, 256);
  
  var res := '';
  while true do
  begin
    if stream.DataAvailable then
    begin
      var readed := stream.Read(buff, 0, buff.Length);
      var str := Encoding.UTF8.GetString(buff, 0, readed);
      
      if str[str.Length] = #3 then
      begin
        res := res + str[1:str.Length];
        break;
      end
      else
        res := res + str;
    end;
  end;
  
  recieve := res;
end;


// <- начало пространства для записи решения
function to_str(num: integer): string;
begin
  var res : string;
  Str(num, res);
  to_str := res;
end;

procedure send_task();
begin
  send('Введите целое четырехзначное число: ');
  
  while true do
  begin
    var str := recieve();
    var num : integer;
    var err : integer;
    Val(str, num, err);
    
    if not (err = 0) then 
    begin
      send('Это точно не целое число, попробуйте снова: ');
      continue;
    end
    else
    begin
      var digits := 0;
      var sum := 0;
      repeat
        digits := digits + 1;
        sum := sum + (num mod 10);
        num := num div 10;
      until num = 0;
      
      if not (digits = 4) then
      begin
        send('Введено не четырехзначное число, попробуйте снова: ');
        continue;
      end;
      
      sendln('Cумма цифр этого числа: ' + to_str(sum));
      break;
    end;
  end;
end;
// <- конец пространства для записи решения


begin
  var srvr: TcpListener := new TcpListener(IPAddress.Any, 4156);
  srvr.Start();
  
  while true do
  begin
    if srvr.Pending() then
    begin
      var connection := srvr.AcceptTcpClient();
      connection.NoDelay := true;
      
      stream := connection.GetStream();
      
      try
        send_task();
        send(#4);
      except on E: Exception do 
        writeln(E.Message); 
      end;
      
      stream.close();
      connection.close();
    end;
  end;
end.