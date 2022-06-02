------------------------------------------------------------------
--Copyright 2022 Andrey S. Ionisyan (anserion@gmail.com)
--Licensed under the Apache License, Version 2.0 (the "License");
--you may not use this file except in compliance with the License.
--You may obtain a copy of the License at
--    http://www.apache.org/licenses/LICENSE-2.0
--Unless required by applicable law or agreed to in writing, software
--distributed under the License is distributed on an "AS IS" BASIS,
--WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--See the License for the specific language governing permissions and
--limitations under the License.
------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Engineer: Andrey S. Ionisyan <anserion@gmail.com>
-- 
-- Description: investigation of continues and discrete 
--              bidirection associative memory neural networks
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_signed.all;

entity bidirmem_top_tb is
end bidirmem_top_tb;

architecture Behavioral of bidirmem_top_tb is

constant n: integer range 0 to 15:=4;
constant cont_bitwide: integer range 0 to 31:=31;
constant discrete_bitwide: integer range 0 to 15:=8;

component bidirmem_network_cont is
	generic (n:integer range 0 to 15 := 4; bitwide:integer range 0 to 31:=31);
    Port ( 
		clk        : in std_logic;
      ask        : in std_logic;
      ready      : out std_logic;

		X: in std_logic_vector(n-1 downto 0);
		L1_W: in std_logic_vector(n*bitwide*n-1 downto 0);
      L2_W: in std_logic_vector(n*bitwide*n-1 downto 0);
		Y: out std_logic_vector(n-1 downto 0)
	);
end component;

component bidirmem_network_discrete is
	generic (n:integer range 0 to 15 := 4; bitwide:integer range 0 to 31:=8);
    Port ( 
		clk        : in std_logic;
      ask        : in std_logic;
      ready      : out std_logic;

		X: in std_logic_vector(n-1 downto 0);
		L1_W: in std_logic_vector(n*bitwide*n-1 downto 0);
      L2_W: in std_logic_vector(n*bitwide*n-1 downto 0);
		Y: out std_logic_vector(n-1 downto 0)		
	 );
end component;

signal bidirmem_cont_ask: std_logic:='0';
signal bidirmem_cont_ready: std_logic:='0';
signal bidirmem_cont_X: std_logic_vector(n-1 downto 0):=(others=>'0');
signal bidirmem_cont_L1_W: std_logic_vector(n*cont_bitwide*n-1 downto 0):=(others=>'0');
signal bidirmem_cont_L2_W: std_logic_vector(n*cont_bitwide*n-1 downto 0):=(others=>'0');
signal bidirmem_cont_Y: std_logic_vector(n-1 downto 0):=(others=>'0');

signal bidirmem_discrete_ask: std_logic:='0';
signal bidirmem_discrete_ready: std_logic:='0';
signal bidirmem_discrete_X: std_logic_vector(n-1 downto 0):=(others=>'0');
signal bidirmem_discrete_L1_W: std_logic_vector(n*discrete_bitwide*n-1 downto 0):=(others=>'0');
signal bidirmem_discrete_L2_W: std_logic_vector(n*discrete_bitwide*n-1 downto 0):=(others=>'0');
signal bidirmem_discrete_Y: std_logic_vector(n-1 downto 0):=(others=>'0');

constant clk_period : time := 100 ns;
signal clk: std_logic:='0';

begin
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

	bidirmem_network_discrete_chip: bidirmem_network_discrete
		generic map (n,discrete_bitwide)
		port map (
			clk, bidirmem_discrete_ask, bidirmem_discrete_ready,
			bidirmem_discrete_X,
         bidirmem_discrete_L1_W, bidirmem_discrete_L2_W,
         bidirmem_discrete_Y
		);

	bidirmem_network_cont_chip: bidirmem_network_cont
		generic map (n,cont_bitwide)
		port map (
			clk, bidirmem_cont_ask, bidirmem_cont_ready,
			bidirmem_cont_X,
         bidirmem_cont_L1_W, bidirmem_cont_L2_W,
         bidirmem_cont_Y
		);
		
	process (clk)
	variable fsm: integer range 0 to 7:=0;
	begin
		if rising_edge(clk) then
		case fsm is
		when 0=>
			bidirmem_cont_ask<='1';
			bidirmem_discrete_ask<='1';
			fsm:=1;
		when 1=>
			if (bidirmem_cont_ready and bidirmem_discrete_ready)='1'
			then bidirmem_cont_ask<='0'; bidirmem_discrete_ask<='0'; fsm:=2;
			end if;
		when 2=> fsm:=0;
		when others=> null;
		end case;
		end if;
	end process;

end Behavioral;
