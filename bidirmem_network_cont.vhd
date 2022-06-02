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
-- Description: vhdl description of continues bidirection associative memory network
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_signed.all;

entity bidirmem_network_cont is
	 generic (n:integer:= 4; bitwide:integer:=32);
    Port ( 
		clk        : in std_logic;
      ask        : in std_logic;
      ready      : out std_logic;
		
		X: in std_logic_vector(n-1 downto 0);
		L1_W: in std_logic_vector(n*bitwide*n-1 downto 0);
      L2_W: in std_logic_vector(n*bitwide*n-1 downto 0);
		Y: out std_logic_vector(n-1 downto 0)
	 );
end bidirmem_network_cont;

architecture Behavioral of bidirmem_network_cont is

component neuron_cont is
	generic (n:integer:= 4; bitwide:integer:=8);
    Port ( 
		X: in std_logic_vector(n-1 downto 0);
		W: in std_logic_vector(bitwide*n-1 downto 0);
		A: out std_logic
	 );
end component;
signal L1_neurons_X: std_logic_vector(n-1 downto 0):=(others=>'0');
signal L1_neurons_A: std_logic_vector(n-1 downto 0):=(others=>'0');
signal L2_neurons_X: std_logic_vector(n-1 downto 0):=(others=>'0');
signal L2_neurons_A: std_logic_vector(n-1 downto 0):=(others=>'0');
constant neurons_ready_cond: std_logic_vector(n-1 downto 0):=(others=>'1');
begin
Y<=L2_neurons_A;

L1_neurons:
	for i in 0 to n-1 generate
	begin
		neuron_chip: neuron_cont
		generic map (n,bitwide)
		port map (L1_neurons_X,	L1_W((i+1)*n*bitwide-1 downto i*n*bitwide), L1_neurons_A(i)
		);
	end generate;

L2_neurons:
	for i in 0 to n-1 generate
	begin
		neuron_chip: neuron_cont
		generic map (n,bitwide)
		port map (L2_neurons_X,	L2_W((i+1)*n*bitwide-1 downto i*n*bitwide), L2_neurons_A(i)
		);
	end generate;
   
	process (clk)
	variable fsm: integer range 0 to 3:=0;
	begin
		if rising_edge(clk) then
		case fsm is
		when 0=> if ask='1' then ready<='0'; fsm:=1; end if;
		when 1=> L2_neurons_X<=L1_neurons_A; L1_neurons_X<=X; fsm:=2;
		when 2=> L1_neurons_X<=L2_neurons_A; fsm:=3;
		when 3=> ready<='1'; if ask='0' then fsm:=0; end if;
		when others=> null;
		end case;
		end if;
	end process;
end Behavioral;
