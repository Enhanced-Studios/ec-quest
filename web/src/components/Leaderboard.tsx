import React, { useState } from 'react';
import { Table } from '@mantine/core';
import { useLocales } from '../providers/LocaleProvider';
import { fetchNui } from '../utils/fetchNui';

const Leaderboard: React.FC = () => {
  const { locale } = useLocales();
  const [leaderboardData, setLeaderboardData] = useState<any[]>([]);

  React.useEffect(() => {
    fetchNui('setLeaderboard').then((data) => {
      setLeaderboardData(data.leaderboard);
    });
  }, []);

  const sortedData = [...leaderboardData].sort((a, b) => {
    if (b.level !== a.level) {
      return b.level - a.level;
    }
    return b.xp - a.xp;
  });

  const rows = sortedData.map((player) => (
    <Table.Tr key={player.name}>
      <Table.Td>{player.level}</Table.Td>
      <Table.Td>{player.name}</Table.Td>
      <Table.Td>{player.xp}</Table.Td>
    </Table.Tr>
  ));

  return (
    <Table.ScrollContainer p="md" type="native" minWidth={400} maxHeight={250}>
      <Table striped highlightOnHover withTableBorder>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>{locale.ui_leaderboard_level}</Table.Th>
            <Table.Th>{locale.ui_leaderboard_player}</Table.Th>
            <Table.Th>{locale.ui_leaderboard_xp}</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>{rows}</Table.Tbody>
      </Table>
    </Table.ScrollContainer>
  );
};

export default Leaderboard;
