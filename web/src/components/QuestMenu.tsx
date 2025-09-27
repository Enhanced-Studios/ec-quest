import React, { useEffect, useState } from 'react';
import {
  BackgroundImage,
  Box,
  Button,
  Center,
  DEFAULT_THEME,
  Divider,
  Grid,
  Group,
  Paper,
  Progress,
  ScrollArea,
  Text,
} from '@mantine/core';
import { useLocales } from '../providers/LocaleProvider';
import { fetchNui } from '../utils/fetchNui';

interface QuestItem {
  name: string;
  count: number;
}

interface Quests {
  name: string;
  id: number;
  reward: number;
  xp: number;
  items: QuestItem[];
  claimed: boolean;
}

const QuestMenu: React.FC = () => {
  const theme = DEFAULT_THEME;
  const { locale } = useLocales();
  const [Quests, setQuests] = useState<Quests[] | null>(null);
  const [playerXP, setPlayerXP] = useState<number[]>([0, 0, 0]);
  const [PrimTheme, setPrimTheme] = useState<string>('grape');

  useEffect(() => {
    if (Quests) return;
    fetchNui('setQuestMenu')
      .then((retData) => {
        setQuests(retData.quests);
        setPrimTheme(retData.theme);
        setPlayerXP(retData.playerXP);
      })
      .catch(() => {
        setPrimTheme('red');
        setPlayerXP([2, 500, 1000]);
        setQuests([
          {
            name: 'Tire 1',
            id: 1,
            reward: 250,
            xp: 500,
            items: [{ name: 'knickers', count: 1 }],
            claimed: false,
          },
        ]);
      });
  }, [Quests]);

  const handleClaim = async (id: number) => {
    const data = await fetchNui<{ success: boolean }>('claimReward', { id });

    if (data?.success) {
      setQuests((prev) =>
        prev ? prev.map((q) => (q.id === id ? { ...q, claimed: true } : q)) : prev
      );
    }
  };

  return (
    <Box m="xs">
      <Group justify="space-between" pb="4px">
        <Text size="xs" c="dimmed">
          {playerXP[0]}
        </Text>
        <Text size="xs" c="dimmed">
          {playerXP[1]}/{playerXP[2]}
        </Text>
        <Text size="xs" c="dimmed">
          {playerXP[0] + 1}
        </Text>
      </Group>
      <Progress
        color={PrimTheme}
        radius="xs"
        size="sm"
        value={playerXP[2] > 0 ? (playerXP[1] / playerXP[2]) * 100 : 0}
      />
      <ScrollArea mt="sm" h={230} type="never">
        <Grid>
          {Quests && Quests.length > 0 ? (
            Quests.map(({ name, id, reward, xp, items, claimed }) => (
              <Grid.Col span={4}>
                <Paper
                  h={220}
                  withBorder
                  radius={4}
                  style={{
                    backgroundColor: theme.colors.dark[7],
                  }}
                >
                  <Group justify="space-between">
                    <Paper
                      w={60}
                      h={20}
                      style={{
                        backgroundColor: theme.colors[PrimTheme][9],
                        opacity: 0.7,
                        borderTopRightRadius: 0,
                        borderBottomLeftRadius: 0,
                        borderTopLeftRadius: 3,
                      }}
                    >
                      <Center h="100%">
                        <Text fw={700} style={{ fontSize: '9px', color: 'white' }} ta="center">
                          +{xp} XP
                        </Text>
                      </Center>
                    </Paper>
                    <Paper
                      w={60}
                      h={20}
                      style={{
                        backgroundColor: theme.colors.green[9],
                        opacity: 0.7,
                        borderTopRightRadius: 3,
                        borderBottomRightRadius: 0,
                        borderTopLeftRadius: 0,
                      }}
                    >
                      <Center h="100%">
                        <Text fw={700} style={{ fontSize: '9px', color: 'white' }} ta="center">
                          +{reward} $
                        </Text>
                      </Center>
                    </Paper>
                  </Group>
                  <Center mt="xs">
                    <Text fw={700} size="xl">
                      {name}
                    </Text>
                  </Center>
                  <Divider mx="md"></Divider>
                  <Box py="sm" px="md" h={110}>
                    <Grid gutter="xs">
                      {items.length === 0 || items.length > 6 ? (
                        <Text ta="center" size="md">
                          {locale.ui_quest_noItems}
                        </Text>
                      ) : (
                        items.map(({ name, count }) => (
                          <Grid.Col span={4}>
                            <Paper
                              h={45.88}
                              w={45.88}
                              withBorder
                              radius={4}
                              style={{
                                backgroundColor: theme.colors.dark[7],
                              }}
                            >
                              <BackgroundImage
                                h={43.44}
                                src={`https://cfx-nui-ox_inventory/web/images/${name}.png`}
                              >
                                <Text mx={2} fw={500} style={{ fontSize: '10px' }}>
                                  {count}x
                                </Text>
                                <Text mt={15} fw={700} ta="center" style={{ fontSize: '9px' }}>
                                  {name}
                                </Text>
                              </BackgroundImage>
                            </Paper>
                          </Grid.Col>
                        ))
                      )}
                    </Grid>
                  </Box>
                  <Group m="sm">
                    <Button
                      fullWidth
                      h={25}
                      variant="light"
                      color={PrimTheme}
                      disabled={claimed}
                      onClick={() => handleClaim(id)}
                    >
                      <Text size="xs">
                        {claimed ? locale.ui_quest_claimed : locale.ui_quest_claim}
                      </Text>
                    </Button>
                  </Group>
                </Paper>
              </Grid.Col>
            ))
          ) : (
            <Text m="md" ta="center" size="md">
              {locale.ui_quest_noQuest}
            </Text>
          )}
        </Grid>
      </ScrollArea>
    </Box>
  );
};

export default QuestMenu;
