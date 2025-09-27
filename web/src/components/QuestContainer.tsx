import React, { useEffect, useState } from 'react';
import { IconCrown, IconX } from '@tabler/icons-react';
import { ActionIcon, Center, Container, DEFAULT_THEME, Group, Paper, Text } from '@mantine/core';
import { useLocales } from '../providers/LocaleProvider';
import { fetchNui } from '../utils/fetchNui.ts';
import Leaderboard from './Leaderboard.tsx';
import QuestMenu from './QuestMenu.tsx';
import classes from './Container.module.css';

const QuestContainer: React.FC = () => {
  const theme = DEFAULT_THEME;
  const { locale } = useLocales();
  const [showLeaderboard, setShowLeaderboard] = useState(false);
  // Initial time (5h 30m 0s)
  const initialSeconds = 5 * 60 * 60 + 30 * 60; // convert to seconds

  const [timeLeft, setTimeLeft] = useState(initialSeconds);

  function handleClose() {
    fetchNui('hide-ui');
  }

  useEffect(() => {
    fetchNui('setRefreshTime').then((data) => {
      setTimeLeft(data.time);
    });

    if (timeLeft <= 0) return;

    const timer = setInterval(() => {
      setTimeLeft((prev) => prev - 1);
    }, 1000);

    return () => clearInterval(timer);
  }, [timeLeft]);

  const formatTime = (totalSeconds: number) => {
    const hours = String(Math.floor(totalSeconds / 3600)).padStart(2, '0');
    const minutes = String(Math.floor((totalSeconds % 3600) / 60)).padStart(2, '0');
    const seconds = String(totalSeconds % 60).padStart(2, '0');
    return `${hours}:${minutes}:${seconds}`;
  };

  return (
    <div style={{ width: '100%', height: '100%', position: 'fixed' }}>
      <Center style={{ width: '100%', height: '100%' }}>
        <Paper
          w={620}
          h={340}
          withBorder
          radius={4}
          style={{
            backgroundColor: theme.colors.dark[8],
          }}
        >
          <header className={classes.header}>
            <Container size="md" className={classes.inner}>
              <Group>
                <Text fw={700} size="lg">
                  {locale.ui_title_quest}
                </Text>
                <Text c="dimmed" size="sm">
                  Refresh: {formatTime(timeLeft)}
                </Text>
              </Group>
              <Group gap={5} visibleFrom="xs">
                <ActionIcon
                  variant="light"
                  color="yellow"
                  aria-label="Leaderboard"
                  onClick={() => setShowLeaderboard((prev) => !prev)}
                >
                  <IconCrown stroke={1.5} />
                </ActionIcon>
                <ActionIcon variant="light" color="red" aria-label="Close" onClick={handleClose}>
                  <IconX stroke={1.5} />
                </ActionIcon>
              </Group>
            </Container>
          </header>
          {showLeaderboard ? <Leaderboard /> : <QuestMenu />}
        </Paper>
      </Center>
    </div>
  );
};

export default QuestContainer;
