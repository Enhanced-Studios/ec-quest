CREATE TABLE IF NOT EXISTS `enhanced_quests_levels` (
  `player` varchar(255) DEFAULT NULL,
  `level` int(11) DEFAULT 1,
  `xp` int(11) DEFAULT 10,
  `name` varchar(255) DEFAULT 'John Doe'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
 