library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all; -- Revisar si se ha de cambiar

entity main is
    port (
    g_clock_50: in std_logic;
    v_sw  : in std_logic_vector (9 downto 0); 
    v_bt  : in std_logic_vector (3 downto 0); 
    g_led : out std_logic_vector(9 downto 0); 
    g_hex0 : out std_logic_vector(0 to 6); 
    g_hex1 : out std_logic_vector(0 to 6);
    g_hex2 : out std_logic_vector(0 to 6);
    g_hex3 : out std_logic_vector(0 to 6);
    g_hex4 : out std_logic_vector(0 to 6);
    g_hex5 : out std_logic_vector(0 to 6) 
    );
end main;

architecture Behavioral of main is

-- Editable

signal contador: std_logic_vector (3 downto 0);
signal contador_base: integer range 0 to 50000000;
signal boton_reinicio: std_logic;
signal led_contador: std_logic_vector(3 downto 0);
signal sw_op_1: std_logic;
signal sw_op_2: std_logic;
signal sw_op_3: std_logic;
signal sw_op_4: std_logic;
signal led_debuger: std_logic;

begin

boton_reinicio<=v_bt(0);
sw_op_1<=v_sw(0); -- ¿Por qué con sw no va?
sw_op_2<=v_sw(2);
sw_op_3<=v_sw(3);
sw_op_4<=v_sw(4);
g_led(3 downto 0)<=led_contador;
g_led(4)<=led_debuger;

process(boton_reinicio, g_clock_50)
begin
   if (boton_reinicio = '0') then -- ¡Botones activos por nivél bajo! --> 0 es pulsado
      contador_base <= 0; -- Si pulsamos inicio reiniciamos el contador base
   elsif rising_edge(g_clock_50) then -- El reloj trabaja a 50MHz (Cada 0,0000002s)
      if (contador_base = 50000000) then -- De esta manera estamos dividiendo 50Mhz entre 50M, por lo que el resultado es 1hz o lo que es lo mismo, 1s
         contador_base <= 0;
      else
         contador_base <= contador_base + 1;
      end if;
   end if;
end process;

process(boton_reinicio,contador_base, g_clock_50)
begin
   if (boton_reinicio = '0') then
      contador <= "0000"; -- Si pulsamos inicio reiniciamos el contador 
   elsif rising_edge(g_clock_50) then -- Se comprueba cada ciclo de reloj, para evitar que se este comprobando constantemente
      if (contador_base = 50000000) then
         if (contador = "1001") then -- Si el contador llega a 9 reiniciamos a 0 (Característica del contador BCD)
            if (sw_op_1 = '1') then -- Si el sw_op_1 esta pulsado, mantenemos el 9
               contador <= "1001";
               led_debuger<= '0';
            else
               contador <= "0000";
               led_debuger <= '1';
            end if;
         else
            contador<=contador+1; 
         end if;
      end if;
   end if;
end process;

process(contador)
begin
   case contador is
      when "0000" => g_hex0 <="0000001";
      when "0001" => g_hex0 <="1001111";
      when "0010" => g_hex0 <="0010010";
      when "0011" => g_hex0 <="0000110";
      when "0100" => g_hex0 <="1001100";
      when "0101" => g_hex0 <="0100100";
      when "0110" => g_hex0 <="1100000";
      when "0111" => g_hex0 <="0001111";
      when "1000" => g_hex0 <="0000000";
      when "1001" => g_hex0 <="0001100";
      when others => g_hex0 <="1111111";
   end case;
   led_contador<= contador;
end process;


end Behavioral;