% Numberlink Puzzle
% # Numberlink Puzzle
% # Author: The Afis Project
% # Source: http://www.afis.to/~start/
% # URL: http://www.janko.at/Raetsel/Arukone/001.a.htm
% size 5 5
%  7  -  -  -  3
%  9  1  3  -  -
%  -  -  -  7  -
%  -  -  -  -  -
%  9  -  -  -  1
node(v_0_0).
node(v_0_1).
node(v_0_2).
node(v_0_3).
node(v_0_4).
node(v_1_0).
node(v_1_1).
node(v_1_2).
node(v_1_3).
node(v_1_4).
node(v_2_0).
node(v_2_1).
node(v_2_2).
node(v_2_3).
node(v_2_4).
node(v_3_0).
node(v_3_1).
node(v_3_2).
node(v_3_3).
node(v_3_4).
node(v_4_0).
node(v_4_1).
node(v_4_2).
node(v_4_3).
node(v_4_4).
edge(e_0_0_1_0, v_0_0, v_1_0).
edge(e_0_0_0_1, v_0_0, v_0_1).
edge(e_0_1_1_1, v_0_1, v_1_1).
edge(e_0_1_0_2, v_0_1, v_0_2).
edge(e_0_2_1_2, v_0_2, v_1_2).
edge(e_0_2_0_3, v_0_2, v_0_3).
edge(e_0_3_1_3, v_0_3, v_1_3).
edge(e_0_3_0_4, v_0_3, v_0_4).
edge(e_0_4_1_4, v_0_4, v_1_4).
edge(e_1_0_2_0, v_1_0, v_2_0).
edge(e_1_0_1_1, v_1_0, v_1_1).
edge(e_1_1_2_1, v_1_1, v_2_1).
edge(e_1_1_1_2, v_1_1, v_1_2).
edge(e_1_2_2_2, v_1_2, v_2_2).
edge(e_1_2_1_3, v_1_2, v_1_3).
edge(e_1_3_2_3, v_1_3, v_2_3).
edge(e_1_3_1_4, v_1_3, v_1_4).
edge(e_1_4_2_4, v_1_4, v_2_4).
edge(e_2_0_3_0, v_2_0, v_3_0).
edge(e_2_0_2_1, v_2_0, v_2_1).
edge(e_2_1_3_1, v_2_1, v_3_1).
edge(e_2_1_2_2, v_2_1, v_2_2).
edge(e_2_2_3_2, v_2_2, v_3_2).
edge(e_2_2_2_3, v_2_2, v_2_3).
edge(e_2_3_3_3, v_2_3, v_3_3).
edge(e_2_3_2_4, v_2_3, v_2_4).
edge(e_2_4_3_4, v_2_4, v_3_4).
edge(e_3_0_4_0, v_3_0, v_4_0).
edge(e_3_0_3_1, v_3_0, v_3_1).
edge(e_3_1_4_1, v_3_1, v_4_1).
edge(e_3_1_3_2, v_3_1, v_3_2).
edge(e_3_2_4_2, v_3_2, v_4_2).
edge(e_3_2_3_3, v_3_2, v_3_3).
edge(e_3_3_4_3, v_3_3, v_4_3).
edge(e_3_3_3_4, v_3_3, v_3_4).
edge(e_3_4_4_4, v_3_4, v_4_4).
edge(e_4_0_4_1, v_4_0, v_4_1).
edge(e_4_1_4_2, v_4_1, v_4_2).
edge(e_4_2_4_3, v_4_2, v_4_3).
edge(e_4_3_4_4, v_4_3, v_4_4).
connection(1, v_1_1, v_4_4).
connection(3, v_0_4, v_1_2).
connection(7, v_0_0, v_2_3).
connection(9, v_1_0, v_4_0).
% END
