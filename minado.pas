program campo_minado;
uses crt;

const 
    COLUNAS = 8;    // aki é linhas
    LINHAS = 6;     //aki é colunas
    nbombs = 10;

type
    tiles = record 
        open : boolean;
        has_bomb : boolean;
        marked : boolean;
        neighbors : integer;
    end;

    board = record
       tile : array [1..COLUNAS, 1..LINHAS] of tiles;
       won : boolean;
       lost : boolean;
    end;

var 
    game : board;
    input : integer;

{################ CRIA O CAMPO ##############*}
procedure make_game(var game : board);
var i,j : integer;
begin
    for i := 1 to COLUNAS do begin
        for j := 1 to LINHAS do begin
            game.tile[i,j].open := false;
            game.tile[i,j].has_bomb := false;
            game.tile[i,j].neighbors := 0;
            game.tile[i,j].marked := false;
        end;
    end;
    game.won := false;
    game.lost := false;
end;
{######### PLANTA AS BOMBAS NO CAMPO #########}
procedure gera_bombas(var game : board);
var l , c, count : integer;
begin
    randomize;
    count := 0;
    while count < nbombs do begin
        l := random(LINHAS ) +1;
        c := random(COLUNAS) +1;
        if not game.tile[c,l].has_bomb then begin
            game.tile[c,l].has_bomb := true; 
            count += 1;
            //writeln('[',c, ', ',l,']');
        end;
    end;
    //game.tile[3,3].has_bomb := false;
end;
{############### CONTA AS BANDEIRAS #################3}
function count_marked(game : board): integer;
var i,j,count : integer;
begin
    count := 0;
    for i := 1 to COLUNAS do
        for j := 1 to LINHAS do 
            if (game.tile[i,j].marked) and (game.tile[i,j].has_bomb) then count += 1;
    
    count_marked:= count;
end;

function respect_borders(a,b : integer):boolean;
begin
    respect_borders := (a <= COLUNAS) and (a >= 1) and (b <= LINHAS) and (b >= 1);
end;
{########## CONTA BOMBAS ADJACENTES ############}
procedure count_neighbors(var game : board);
var i,j,a,b,x,y, count  : integer;
begin

    count := 0;
    for i := 1 to COLUNAS do begin
        for j := 1 to LINHAS do begin

            for a := -1 to 1 do begin
                for b := -1 to 1 do begin
                    x := a+i; 
                    y := b+j;
                    if respect_borders(x,y) and (game.tile[x, y].has_bomb) then count += 1;
                end;
            end;
                game.tile[i,j].neighbors := count;
                count := 0;
        end;
    end;
end;

procedure open_all(var game : board);
var i,j : integer;
begin
    for i := 1 to COLUNAS do
        for j := 1 to LINHAS do
            game.tile[i,j].open := true;
end;
{################ REGRAS DO JOGO ################333}
function follow_rule(game : board; a,b,mode : integer):boolean;
begin
    if game.tile[a,b].open then begin 
        writeln('this tile was already open'); 
        follow_rule := false; 
        delay(2000);
    end
    else if (not respect_borders(a,b)) then begin 
        writeln('this tile is not on the board'); 
        follow_rule := false;
        delay(2000);
    end
    else if (mode <> 1 ) and (mode <> 2) and (mode <> 3) and (mode <> 4) then begin
        writeln('invalid mode');
        follow_rule := false;
        delay(1000);
    end
    else
        follow_rule := true;
end;
{######## ABRE/MARCA POSIÇÕES NO CAMPO ##########}
procedure dig(var game : board; x, y, mode : integer);
var i,j,a,b : integer;
begin
    //dig
    case mode of 
    1 : begin

        game.tile[x,y].open := true;
        if game.tile[x,y].has_bomb then game.lost := true
        else if (not game.tile[x,y].has_bomb) and (game.tile[x,y].neighbors = 0) then begin
            for a := -1 to 1 do begin
                for b := -1 to 1 do begin
                    i := a+x;
                    j := b+y;
                    if respect_borders(i,j) then
                        if (not game.tile[i, j].has_bomb) and  (not game.tile[i,j].open) then begin 
                            game.tile[i,j].open := true;
                            if game.tile[i,j].neighbors = 0 then dig(game, i, j, 1);
                        end;
                end;
            end;
        end
        else if game.tile[x,y].neighbors <> 0 then
            game.tile[x,y].open := true;
    end;

    //mark
    2 : game.tile[x,y].marked := true;
    3 : game.tile[x,y].marked := false;
    end;

end;
{######### MOSTRA NO TERMINAL O ESTADO DO JOGO ###########}
procedure display(var game : board);
var i,j,k : integer;
begin

    for i := 1 to COLUNAS do begin

        for k := 1 to LINHAS do begin    // U.I.
            if k = 1 then write('     ');
            write('+---')  
        end;
        writeln('+');

        if i < 10 then write('  ', i, '  ')          //position col
        else write(' ', i, '  ');
        
        for j := 1 to LINHAS do begin    // CONTENT OF TILE 
           if (not game.tile[i,j].open) and (not game.tile[i,j].marked) then write('| * ')  
           else if (game.tile[i,j].marked) and (not game.tile[i,j].open) then write('| X ')
           else  if game.tile[i,j].open then begin
                if game.tile[i,j].has_bomb and (not game.tile[i,j].marked) then write('|###')
                else if game.tile[i,j].has_bomb and game.tile[i,j].marked then write('|#X#')
                else if (game.tile[i,j].neighbors > 0) then write('| ', game.tile[i,j].neighbors, ' ')
                else write('|   ');
           end;
        end;

        writeln('|');
    end;

    for k := 1 to LINHAS do begin                //U.I.
            if k = 1 then write('     ');
            write('+---');  end;
    writeln('+');

    write('     ');
    for k := 1 to LINHAS do begin   // position rows
        if k < 10 then write('  ', k, ' ') 
        else     write(' ', k, ' ');   end;
    writeln;

end;
{############## GAME LOOP ###############}
procedure play(var game : board);
var a,b,mode : integer;
begin
    make_game(game);
    gera_bombas(game);
    count_neighbors(game);

    while (not game.won) and (not game.lost) do begin
        clrscr;
        display(game);
        writeln('  modos: 1-> abre | 2 -> marca | 3-> desmarca | 4-> sair');
        write('  modo: ');  readln(mode);
        case mode of 
            1 : begin
                    write('  abrir linha: '); readln(a); 
                    write('  na coluna: ');  readln(b);
                end;
            2 : begin
                    write('  marcar a linha: '); readln(a); 
                    write('  na coluna: ');  readln(b);
                end;
            3 : begin
                    write('  desmarcar a linha: '); readln(a); 
                    write('  na coluna: ');  readln(b);
                end; 
            4 : game.won := true;
        end;
        if mode <> 4 then begin
            if follow_rule(game, a, b, mode) then dig(game, a, b, mode);
            if count_marked(game) = nbombs then game.won := true;
        end;
    end; 
    clrscr;
    open_all(game);
    display(game);

    writeln;
    if game.lost then writeln('          GAME OVER')
    else writeln('     YOU WON!!!');
    writeln;

end;

begin
    input := 1;
    clrscr;
    repeat
        writeln('  digite 1 para jogar');
        writeln('  digite 0 para sair');
        write('  escolha: ');
        read(input);
        case input of 
            1 : play(game);
        end;
    until (input = 0);
    clrscr;
end.

{ made by Eu Próprio in partnership with Comigo Mesmo }