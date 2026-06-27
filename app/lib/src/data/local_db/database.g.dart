// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageBandMeta = const VerificationMeta(
    'ageBand',
  );
  @override
  late final GeneratedColumn<String> ageBand = GeneratedColumn<String>(
    'age_band',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supportModeMeta = const VerificationMeta(
    'supportMode',
  );
  @override
  late final GeneratedColumn<String> supportMode = GeneratedColumn<String>(
    'support_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Normal'),
  );
  static const VerificationMeta _engagementStateMeta = const VerificationMeta(
    'engagementState',
  );
  @override
  late final GeneratedColumn<String> engagementState = GeneratedColumn<String>(
    'engagement_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Active'),
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Asia/Jakarta'),
  );
  static const VerificationMeta _weekStartDayMeta = const VerificationMeta(
    'weekStartDay',
  );
  @override
  late final GeneratedColumn<int> weekStartDay = GeneratedColumn<int>(
    'week_start_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _latestDomainScoresMeta =
      const VerificationMeta('latestDomainScores');
  @override
  late final GeneratedColumn<String> latestDomainScores =
      GeneratedColumn<String>(
        'latest_domain_scores',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _canopyLoadCapacityMeta =
      const VerificationMeta('canopyLoadCapacity');
  @override
  late final GeneratedColumn<int> canopyLoadCapacity = GeneratedColumn<int>(
    'canopy_load_capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _wellnessDisclaimerAcknowledgedMeta =
      const VerificationMeta('wellnessDisclaimerAcknowledged');
  @override
  late final GeneratedColumn<bool> wellnessDisclaimerAcknowledged =
      GeneratedColumn<bool>(
        'wellness_disclaimer_acknowledged',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("wellness_disclaimer_acknowledged" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _lastWellnessPushAtMeta =
      const VerificationMeta('lastWellnessPushAt');
  @override
  late final GeneratedColumn<DateTime> lastWellnessPushAt =
      GeneratedColumn<DateTime>(
        'last_wellness_push_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastWellnessPromptAtMeta =
      const VerificationMeta('lastWellnessPromptAt');
  @override
  late final GeneratedColumn<DateTime> lastWellnessPromptAt =
      GeneratedColumn<DateTime>(
        'last_wellness_prompt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _selectedSkinMeta = const VerificationMeta(
    'selectedSkin',
  );
  @override
  late final GeneratedColumn<String> selectedSkin = GeneratedColumn<String>(
    'selected_skin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Default'),
  );
  static const VerificationMeta _unlockedSkinsMeta = const VerificationMeta(
    'unlockedSkins',
  );
  @override
  late final GeneratedColumn<String> unlockedSkins = GeneratedColumn<String>(
    'unlocked_skins',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Default'),
  );
  static const VerificationMeta _securityLevelMeta = const VerificationMeta(
    'securityLevel',
  );
  @override
  late final GeneratedColumn<String> securityLevel = GeneratedColumn<String>(
    'security_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Local'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('System'),
  );
  static const VerificationMeta _coreValuesMeta = const VerificationMeta(
    'coreValues',
  );
  @override
  late final GeneratedColumn<String> coreValues = GeneratedColumn<String>(
    'core_values',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    ageBand,
    supportMode,
    engagementState,
    timezone,
    weekStartDay,
    latestDomainScores,
    canopyLoadCapacity,
    wellnessDisclaimerAcknowledged,
    lastWellnessPushAt,
    lastWellnessPromptAt,
    selectedSkin,
    unlockedSkins,
    securityLevel,
    createdAt,
    updatedAt,
    deletedAt,
    themeMode,
    coreValues,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('age_band')) {
      context.handle(
        _ageBandMeta,
        ageBand.isAcceptableOrUnknown(data['age_band']!, _ageBandMeta),
      );
    } else if (isInserting) {
      context.missing(_ageBandMeta);
    }
    if (data.containsKey('support_mode')) {
      context.handle(
        _supportModeMeta,
        supportMode.isAcceptableOrUnknown(
          data['support_mode']!,
          _supportModeMeta,
        ),
      );
    }
    if (data.containsKey('engagement_state')) {
      context.handle(
        _engagementStateMeta,
        engagementState.isAcceptableOrUnknown(
          data['engagement_state']!,
          _engagementStateMeta,
        ),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('week_start_day')) {
      context.handle(
        _weekStartDayMeta,
        weekStartDay.isAcceptableOrUnknown(
          data['week_start_day']!,
          _weekStartDayMeta,
        ),
      );
    }
    if (data.containsKey('latest_domain_scores')) {
      context.handle(
        _latestDomainScoresMeta,
        latestDomainScores.isAcceptableOrUnknown(
          data['latest_domain_scores']!,
          _latestDomainScoresMeta,
        ),
      );
    }
    if (data.containsKey('canopy_load_capacity')) {
      context.handle(
        _canopyLoadCapacityMeta,
        canopyLoadCapacity.isAcceptableOrUnknown(
          data['canopy_load_capacity']!,
          _canopyLoadCapacityMeta,
        ),
      );
    }
    if (data.containsKey('wellness_disclaimer_acknowledged')) {
      context.handle(
        _wellnessDisclaimerAcknowledgedMeta,
        wellnessDisclaimerAcknowledged.isAcceptableOrUnknown(
          data['wellness_disclaimer_acknowledged']!,
          _wellnessDisclaimerAcknowledgedMeta,
        ),
      );
    }
    if (data.containsKey('last_wellness_push_at')) {
      context.handle(
        _lastWellnessPushAtMeta,
        lastWellnessPushAt.isAcceptableOrUnknown(
          data['last_wellness_push_at']!,
          _lastWellnessPushAtMeta,
        ),
      );
    }
    if (data.containsKey('last_wellness_prompt_at')) {
      context.handle(
        _lastWellnessPromptAtMeta,
        lastWellnessPromptAt.isAcceptableOrUnknown(
          data['last_wellness_prompt_at']!,
          _lastWellnessPromptAtMeta,
        ),
      );
    }
    if (data.containsKey('selected_skin')) {
      context.handle(
        _selectedSkinMeta,
        selectedSkin.isAcceptableOrUnknown(
          data['selected_skin']!,
          _selectedSkinMeta,
        ),
      );
    }
    if (data.containsKey('unlocked_skins')) {
      context.handle(
        _unlockedSkinsMeta,
        unlockedSkins.isAcceptableOrUnknown(
          data['unlocked_skins']!,
          _unlockedSkinsMeta,
        ),
      );
    }
    if (data.containsKey('security_level')) {
      context.handle(
        _securityLevelMeta,
        securityLevel.isAcceptableOrUnknown(
          data['security_level']!,
          _securityLevelMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('core_values')) {
      context.handle(
        _coreValuesMeta,
        coreValues.isAcceptableOrUnknown(data['core_values']!, _coreValuesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      ageBand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}age_band'],
      )!,
      supportMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}support_mode'],
      )!,
      engagementState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engagement_state'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      weekStartDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_start_day'],
      )!,
      latestDomainScores: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_domain_scores'],
      ),
      canopyLoadCapacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}canopy_load_capacity'],
      )!,
      wellnessDisclaimerAcknowledged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}wellness_disclaimer_acknowledged'],
      )!,
      lastWellnessPushAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_wellness_push_at'],
      ),
      lastWellnessPromptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_wellness_prompt_at'],
      ),
      selectedSkin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_skin'],
      )!,
      unlockedSkins: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unlocked_skins'],
      )!,
      securityLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}security_level'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      coreValues: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}core_values'],
      ),
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String userId;
  final String ageBand;
  final String supportMode;
  final String engagementState;
  final String timezone;
  final int weekStartDay;
  final String? latestDomainScores;
  final int canopyLoadCapacity;
  final bool wellnessDisclaimerAcknowledged;
  final DateTime? lastWellnessPushAt;
  final DateTime? lastWellnessPromptAt;
  final String selectedSkin;
  final String unlockedSkins;
  final String securityLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String themeMode;
  final String? coreValues;
  const UserProfile({
    required this.userId,
    required this.ageBand,
    required this.supportMode,
    required this.engagementState,
    required this.timezone,
    required this.weekStartDay,
    this.latestDomainScores,
    required this.canopyLoadCapacity,
    required this.wellnessDisclaimerAcknowledged,
    this.lastWellnessPushAt,
    this.lastWellnessPromptAt,
    required this.selectedSkin,
    required this.unlockedSkins,
    required this.securityLevel,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.themeMode,
    this.coreValues,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['age_band'] = Variable<String>(ageBand);
    map['support_mode'] = Variable<String>(supportMode);
    map['engagement_state'] = Variable<String>(engagementState);
    map['timezone'] = Variable<String>(timezone);
    map['week_start_day'] = Variable<int>(weekStartDay);
    if (!nullToAbsent || latestDomainScores != null) {
      map['latest_domain_scores'] = Variable<String>(latestDomainScores);
    }
    map['canopy_load_capacity'] = Variable<int>(canopyLoadCapacity);
    map['wellness_disclaimer_acknowledged'] = Variable<bool>(
      wellnessDisclaimerAcknowledged,
    );
    if (!nullToAbsent || lastWellnessPushAt != null) {
      map['last_wellness_push_at'] = Variable<DateTime>(lastWellnessPushAt);
    }
    if (!nullToAbsent || lastWellnessPromptAt != null) {
      map['last_wellness_prompt_at'] = Variable<DateTime>(lastWellnessPromptAt);
    }
    map['selected_skin'] = Variable<String>(selectedSkin);
    map['unlocked_skins'] = Variable<String>(unlockedSkins);
    map['security_level'] = Variable<String>(securityLevel);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['theme_mode'] = Variable<String>(themeMode);
    if (!nullToAbsent || coreValues != null) {
      map['core_values'] = Variable<String>(coreValues);
    }
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      userId: Value(userId),
      ageBand: Value(ageBand),
      supportMode: Value(supportMode),
      engagementState: Value(engagementState),
      timezone: Value(timezone),
      weekStartDay: Value(weekStartDay),
      latestDomainScores: latestDomainScores == null && nullToAbsent
          ? const Value.absent()
          : Value(latestDomainScores),
      canopyLoadCapacity: Value(canopyLoadCapacity),
      wellnessDisclaimerAcknowledged: Value(wellnessDisclaimerAcknowledged),
      lastWellnessPushAt: lastWellnessPushAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWellnessPushAt),
      lastWellnessPromptAt: lastWellnessPromptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWellnessPromptAt),
      selectedSkin: Value(selectedSkin),
      unlockedSkins: Value(unlockedSkins),
      securityLevel: Value(securityLevel),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      themeMode: Value(themeMode),
      coreValues: coreValues == null && nullToAbsent
          ? const Value.absent()
          : Value(coreValues),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      userId: serializer.fromJson<String>(json['userId']),
      ageBand: serializer.fromJson<String>(json['ageBand']),
      supportMode: serializer.fromJson<String>(json['supportMode']),
      engagementState: serializer.fromJson<String>(json['engagementState']),
      timezone: serializer.fromJson<String>(json['timezone']),
      weekStartDay: serializer.fromJson<int>(json['weekStartDay']),
      latestDomainScores: serializer.fromJson<String?>(
        json['latestDomainScores'],
      ),
      canopyLoadCapacity: serializer.fromJson<int>(json['canopyLoadCapacity']),
      wellnessDisclaimerAcknowledged: serializer.fromJson<bool>(
        json['wellnessDisclaimerAcknowledged'],
      ),
      lastWellnessPushAt: serializer.fromJson<DateTime?>(
        json['lastWellnessPushAt'],
      ),
      lastWellnessPromptAt: serializer.fromJson<DateTime?>(
        json['lastWellnessPromptAt'],
      ),
      selectedSkin: serializer.fromJson<String>(json['selectedSkin']),
      unlockedSkins: serializer.fromJson<String>(json['unlockedSkins']),
      securityLevel: serializer.fromJson<String>(json['securityLevel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      coreValues: serializer.fromJson<String?>(json['coreValues']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'ageBand': serializer.toJson<String>(ageBand),
      'supportMode': serializer.toJson<String>(supportMode),
      'engagementState': serializer.toJson<String>(engagementState),
      'timezone': serializer.toJson<String>(timezone),
      'weekStartDay': serializer.toJson<int>(weekStartDay),
      'latestDomainScores': serializer.toJson<String?>(latestDomainScores),
      'canopyLoadCapacity': serializer.toJson<int>(canopyLoadCapacity),
      'wellnessDisclaimerAcknowledged': serializer.toJson<bool>(
        wellnessDisclaimerAcknowledged,
      ),
      'lastWellnessPushAt': serializer.toJson<DateTime?>(lastWellnessPushAt),
      'lastWellnessPromptAt': serializer.toJson<DateTime?>(
        lastWellnessPromptAt,
      ),
      'selectedSkin': serializer.toJson<String>(selectedSkin),
      'unlockedSkins': serializer.toJson<String>(unlockedSkins),
      'securityLevel': serializer.toJson<String>(securityLevel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'themeMode': serializer.toJson<String>(themeMode),
      'coreValues': serializer.toJson<String?>(coreValues),
    };
  }

  UserProfile copyWith({
    String? userId,
    String? ageBand,
    String? supportMode,
    String? engagementState,
    String? timezone,
    int? weekStartDay,
    Value<String?> latestDomainScores = const Value.absent(),
    int? canopyLoadCapacity,
    bool? wellnessDisclaimerAcknowledged,
    Value<DateTime?> lastWellnessPushAt = const Value.absent(),
    Value<DateTime?> lastWellnessPromptAt = const Value.absent(),
    String? selectedSkin,
    String? unlockedSkins,
    String? securityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? themeMode,
    Value<String?> coreValues = const Value.absent(),
  }) => UserProfile(
    userId: userId ?? this.userId,
    ageBand: ageBand ?? this.ageBand,
    supportMode: supportMode ?? this.supportMode,
    engagementState: engagementState ?? this.engagementState,
    timezone: timezone ?? this.timezone,
    weekStartDay: weekStartDay ?? this.weekStartDay,
    latestDomainScores: latestDomainScores.present
        ? latestDomainScores.value
        : this.latestDomainScores,
    canopyLoadCapacity: canopyLoadCapacity ?? this.canopyLoadCapacity,
    wellnessDisclaimerAcknowledged:
        wellnessDisclaimerAcknowledged ?? this.wellnessDisclaimerAcknowledged,
    lastWellnessPushAt: lastWellnessPushAt.present
        ? lastWellnessPushAt.value
        : this.lastWellnessPushAt,
    lastWellnessPromptAt: lastWellnessPromptAt.present
        ? lastWellnessPromptAt.value
        : this.lastWellnessPromptAt,
    selectedSkin: selectedSkin ?? this.selectedSkin,
    unlockedSkins: unlockedSkins ?? this.unlockedSkins,
    securityLevel: securityLevel ?? this.securityLevel,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    themeMode: themeMode ?? this.themeMode,
    coreValues: coreValues.present ? coreValues.value : this.coreValues,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      userId: data.userId.present ? data.userId.value : this.userId,
      ageBand: data.ageBand.present ? data.ageBand.value : this.ageBand,
      supportMode: data.supportMode.present
          ? data.supportMode.value
          : this.supportMode,
      engagementState: data.engagementState.present
          ? data.engagementState.value
          : this.engagementState,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      weekStartDay: data.weekStartDay.present
          ? data.weekStartDay.value
          : this.weekStartDay,
      latestDomainScores: data.latestDomainScores.present
          ? data.latestDomainScores.value
          : this.latestDomainScores,
      canopyLoadCapacity: data.canopyLoadCapacity.present
          ? data.canopyLoadCapacity.value
          : this.canopyLoadCapacity,
      wellnessDisclaimerAcknowledged:
          data.wellnessDisclaimerAcknowledged.present
          ? data.wellnessDisclaimerAcknowledged.value
          : this.wellnessDisclaimerAcknowledged,
      lastWellnessPushAt: data.lastWellnessPushAt.present
          ? data.lastWellnessPushAt.value
          : this.lastWellnessPushAt,
      lastWellnessPromptAt: data.lastWellnessPromptAt.present
          ? data.lastWellnessPromptAt.value
          : this.lastWellnessPromptAt,
      selectedSkin: data.selectedSkin.present
          ? data.selectedSkin.value
          : this.selectedSkin,
      unlockedSkins: data.unlockedSkins.present
          ? data.unlockedSkins.value
          : this.unlockedSkins,
      securityLevel: data.securityLevel.present
          ? data.securityLevel.value
          : this.securityLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      coreValues: data.coreValues.present
          ? data.coreValues.value
          : this.coreValues,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('userId: $userId, ')
          ..write('ageBand: $ageBand, ')
          ..write('supportMode: $supportMode, ')
          ..write('engagementState: $engagementState, ')
          ..write('timezone: $timezone, ')
          ..write('weekStartDay: $weekStartDay, ')
          ..write('latestDomainScores: $latestDomainScores, ')
          ..write('canopyLoadCapacity: $canopyLoadCapacity, ')
          ..write(
            'wellnessDisclaimerAcknowledged: $wellnessDisclaimerAcknowledged, ',
          )
          ..write('lastWellnessPushAt: $lastWellnessPushAt, ')
          ..write('lastWellnessPromptAt: $lastWellnessPromptAt, ')
          ..write('selectedSkin: $selectedSkin, ')
          ..write('unlockedSkins: $unlockedSkins, ')
          ..write('securityLevel: $securityLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('themeMode: $themeMode, ')
          ..write('coreValues: $coreValues')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    ageBand,
    supportMode,
    engagementState,
    timezone,
    weekStartDay,
    latestDomainScores,
    canopyLoadCapacity,
    wellnessDisclaimerAcknowledged,
    lastWellnessPushAt,
    lastWellnessPromptAt,
    selectedSkin,
    unlockedSkins,
    securityLevel,
    createdAt,
    updatedAt,
    deletedAt,
    themeMode,
    coreValues,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.userId == this.userId &&
          other.ageBand == this.ageBand &&
          other.supportMode == this.supportMode &&
          other.engagementState == this.engagementState &&
          other.timezone == this.timezone &&
          other.weekStartDay == this.weekStartDay &&
          other.latestDomainScores == this.latestDomainScores &&
          other.canopyLoadCapacity == this.canopyLoadCapacity &&
          other.wellnessDisclaimerAcknowledged ==
              this.wellnessDisclaimerAcknowledged &&
          other.lastWellnessPushAt == this.lastWellnessPushAt &&
          other.lastWellnessPromptAt == this.lastWellnessPromptAt &&
          other.selectedSkin == this.selectedSkin &&
          other.unlockedSkins == this.unlockedSkins &&
          other.securityLevel == this.securityLevel &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.themeMode == this.themeMode &&
          other.coreValues == this.coreValues);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> userId;
  final Value<String> ageBand;
  final Value<String> supportMode;
  final Value<String> engagementState;
  final Value<String> timezone;
  final Value<int> weekStartDay;
  final Value<String?> latestDomainScores;
  final Value<int> canopyLoadCapacity;
  final Value<bool> wellnessDisclaimerAcknowledged;
  final Value<DateTime?> lastWellnessPushAt;
  final Value<DateTime?> lastWellnessPromptAt;
  final Value<String> selectedSkin;
  final Value<String> unlockedSkins;
  final Value<String> securityLevel;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> themeMode;
  final Value<String?> coreValues;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.userId = const Value.absent(),
    this.ageBand = const Value.absent(),
    this.supportMode = const Value.absent(),
    this.engagementState = const Value.absent(),
    this.timezone = const Value.absent(),
    this.weekStartDay = const Value.absent(),
    this.latestDomainScores = const Value.absent(),
    this.canopyLoadCapacity = const Value.absent(),
    this.wellnessDisclaimerAcknowledged = const Value.absent(),
    this.lastWellnessPushAt = const Value.absent(),
    this.lastWellnessPromptAt = const Value.absent(),
    this.selectedSkin = const Value.absent(),
    this.unlockedSkins = const Value.absent(),
    this.securityLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.coreValues = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String userId,
    required String ageBand,
    this.supportMode = const Value.absent(),
    this.engagementState = const Value.absent(),
    this.timezone = const Value.absent(),
    this.weekStartDay = const Value.absent(),
    this.latestDomainScores = const Value.absent(),
    this.canopyLoadCapacity = const Value.absent(),
    this.wellnessDisclaimerAcknowledged = const Value.absent(),
    this.lastWellnessPushAt = const Value.absent(),
    this.lastWellnessPromptAt = const Value.absent(),
    this.selectedSkin = const Value.absent(),
    this.unlockedSkins = const Value.absent(),
    this.securityLevel = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.coreValues = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       ageBand = Value(ageBand),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<String>? userId,
    Expression<String>? ageBand,
    Expression<String>? supportMode,
    Expression<String>? engagementState,
    Expression<String>? timezone,
    Expression<int>? weekStartDay,
    Expression<String>? latestDomainScores,
    Expression<int>? canopyLoadCapacity,
    Expression<bool>? wellnessDisclaimerAcknowledged,
    Expression<DateTime>? lastWellnessPushAt,
    Expression<DateTime>? lastWellnessPromptAt,
    Expression<String>? selectedSkin,
    Expression<String>? unlockedSkins,
    Expression<String>? securityLevel,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? themeMode,
    Expression<String>? coreValues,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (ageBand != null) 'age_band': ageBand,
      if (supportMode != null) 'support_mode': supportMode,
      if (engagementState != null) 'engagement_state': engagementState,
      if (timezone != null) 'timezone': timezone,
      if (weekStartDay != null) 'week_start_day': weekStartDay,
      if (latestDomainScores != null)
        'latest_domain_scores': latestDomainScores,
      if (canopyLoadCapacity != null)
        'canopy_load_capacity': canopyLoadCapacity,
      if (wellnessDisclaimerAcknowledged != null)
        'wellness_disclaimer_acknowledged': wellnessDisclaimerAcknowledged,
      if (lastWellnessPushAt != null)
        'last_wellness_push_at': lastWellnessPushAt,
      if (lastWellnessPromptAt != null)
        'last_wellness_prompt_at': lastWellnessPromptAt,
      if (selectedSkin != null) 'selected_skin': selectedSkin,
      if (unlockedSkins != null) 'unlocked_skins': unlockedSkins,
      if (securityLevel != null) 'security_level': securityLevel,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (themeMode != null) 'theme_mode': themeMode,
      if (coreValues != null) 'core_values': coreValues,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? userId,
    Value<String>? ageBand,
    Value<String>? supportMode,
    Value<String>? engagementState,
    Value<String>? timezone,
    Value<int>? weekStartDay,
    Value<String?>? latestDomainScores,
    Value<int>? canopyLoadCapacity,
    Value<bool>? wellnessDisclaimerAcknowledged,
    Value<DateTime?>? lastWellnessPushAt,
    Value<DateTime?>? lastWellnessPromptAt,
    Value<String>? selectedSkin,
    Value<String>? unlockedSkins,
    Value<String>? securityLevel,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? themeMode,
    Value<String?>? coreValues,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      userId: userId ?? this.userId,
      ageBand: ageBand ?? this.ageBand,
      supportMode: supportMode ?? this.supportMode,
      engagementState: engagementState ?? this.engagementState,
      timezone: timezone ?? this.timezone,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      latestDomainScores: latestDomainScores ?? this.latestDomainScores,
      canopyLoadCapacity: canopyLoadCapacity ?? this.canopyLoadCapacity,
      wellnessDisclaimerAcknowledged:
          wellnessDisclaimerAcknowledged ?? this.wellnessDisclaimerAcknowledged,
      lastWellnessPushAt: lastWellnessPushAt ?? this.lastWellnessPushAt,
      lastWellnessPromptAt: lastWellnessPromptAt ?? this.lastWellnessPromptAt,
      selectedSkin: selectedSkin ?? this.selectedSkin,
      unlockedSkins: unlockedSkins ?? this.unlockedSkins,
      securityLevel: securityLevel ?? this.securityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      themeMode: themeMode ?? this.themeMode,
      coreValues: coreValues ?? this.coreValues,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (ageBand.present) {
      map['age_band'] = Variable<String>(ageBand.value);
    }
    if (supportMode.present) {
      map['support_mode'] = Variable<String>(supportMode.value);
    }
    if (engagementState.present) {
      map['engagement_state'] = Variable<String>(engagementState.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (weekStartDay.present) {
      map['week_start_day'] = Variable<int>(weekStartDay.value);
    }
    if (latestDomainScores.present) {
      map['latest_domain_scores'] = Variable<String>(latestDomainScores.value);
    }
    if (canopyLoadCapacity.present) {
      map['canopy_load_capacity'] = Variable<int>(canopyLoadCapacity.value);
    }
    if (wellnessDisclaimerAcknowledged.present) {
      map['wellness_disclaimer_acknowledged'] = Variable<bool>(
        wellnessDisclaimerAcknowledged.value,
      );
    }
    if (lastWellnessPushAt.present) {
      map['last_wellness_push_at'] = Variable<DateTime>(
        lastWellnessPushAt.value,
      );
    }
    if (lastWellnessPromptAt.present) {
      map['last_wellness_prompt_at'] = Variable<DateTime>(
        lastWellnessPromptAt.value,
      );
    }
    if (selectedSkin.present) {
      map['selected_skin'] = Variable<String>(selectedSkin.value);
    }
    if (unlockedSkins.present) {
      map['unlocked_skins'] = Variable<String>(unlockedSkins.value);
    }
    if (securityLevel.present) {
      map['security_level'] = Variable<String>(securityLevel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (coreValues.present) {
      map['core_values'] = Variable<String>(coreValues.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('ageBand: $ageBand, ')
          ..write('supportMode: $supportMode, ')
          ..write('engagementState: $engagementState, ')
          ..write('timezone: $timezone, ')
          ..write('weekStartDay: $weekStartDay, ')
          ..write('latestDomainScores: $latestDomainScores, ')
          ..write('canopyLoadCapacity: $canopyLoadCapacity, ')
          ..write(
            'wellnessDisclaimerAcknowledged: $wellnessDisclaimerAcknowledged, ',
          )
          ..write('lastWellnessPushAt: $lastWellnessPushAt, ')
          ..write('lastWellnessPromptAt: $lastWellnessPromptAt, ')
          ..write('selectedSkin: $selectedSkin, ')
          ..write('unlockedSkins: $unlockedSkins, ')
          ..write('securityLevel: $securityLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('themeMode: $themeMode, ')
          ..write('coreValues: $coreValues, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeAuditsTable extends LifeAudits
    with TableInfo<$LifeAuditsTable, LifeAudit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeAuditsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _auditIdMeta = const VerificationMeta(
    'auditId',
  );
  @override
  late final GeneratedColumn<String> auditId = GeneratedColumn<String>(
    'audit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainScoresMeta = const VerificationMeta(
    'domainScores',
  );
  @override
  late final GeneratedColumn<String> domainScores = GeneratedColumn<String>(
    'domain_scores',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    auditId,
    userId,
    domainScores,
    timestamp,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'life_audits';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeAudit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('audit_id')) {
      context.handle(
        _auditIdMeta,
        auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta),
      );
    } else if (isInserting) {
      context.missing(_auditIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('domain_scores')) {
      context.handle(
        _domainScoresMeta,
        domainScores.isAcceptableOrUnknown(
          data['domain_scores']!,
          _domainScoresMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_domainScoresMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {auditId};
  @override
  LifeAudit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeAudit(
      auditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      domainScores: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain_scores'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LifeAuditsTable createAlias(String alias) {
    return $LifeAuditsTable(attachedDatabase, alias);
  }
}

class LifeAudit extends DataClass implements Insertable<LifeAudit> {
  final String auditId;
  final String userId;
  final String domainScores;
  final DateTime timestamp;
  final DateTime? deletedAt;
  const LifeAudit({
    required this.auditId,
    required this.userId,
    required this.domainScores,
    required this.timestamp,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['audit_id'] = Variable<String>(auditId);
    map['user_id'] = Variable<String>(userId);
    map['domain_scores'] = Variable<String>(domainScores);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LifeAuditsCompanion toCompanion(bool nullToAbsent) {
    return LifeAuditsCompanion(
      auditId: Value(auditId),
      userId: Value(userId),
      domainScores: Value(domainScores),
      timestamp: Value(timestamp),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LifeAudit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeAudit(
      auditId: serializer.fromJson<String>(json['auditId']),
      userId: serializer.fromJson<String>(json['userId']),
      domainScores: serializer.fromJson<String>(json['domainScores']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'auditId': serializer.toJson<String>(auditId),
      'userId': serializer.toJson<String>(userId),
      'domainScores': serializer.toJson<String>(domainScores),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LifeAudit copyWith({
    String? auditId,
    String? userId,
    String? domainScores,
    DateTime? timestamp,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LifeAudit(
    auditId: auditId ?? this.auditId,
    userId: userId ?? this.userId,
    domainScores: domainScores ?? this.domainScores,
    timestamp: timestamp ?? this.timestamp,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LifeAudit copyWithCompanion(LifeAuditsCompanion data) {
    return LifeAudit(
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
      userId: data.userId.present ? data.userId.value : this.userId,
      domainScores: data.domainScores.present
          ? data.domainScores.value
          : this.domainScores,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeAudit(')
          ..write('auditId: $auditId, ')
          ..write('userId: $userId, ')
          ..write('domainScores: $domainScores, ')
          ..write('timestamp: $timestamp, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(auditId, userId, domainScores, timestamp, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeAudit &&
          other.auditId == this.auditId &&
          other.userId == this.userId &&
          other.domainScores == this.domainScores &&
          other.timestamp == this.timestamp &&
          other.deletedAt == this.deletedAt);
}

class LifeAuditsCompanion extends UpdateCompanion<LifeAudit> {
  final Value<String> auditId;
  final Value<String> userId;
  final Value<String> domainScores;
  final Value<DateTime> timestamp;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LifeAuditsCompanion({
    this.auditId = const Value.absent(),
    this.userId = const Value.absent(),
    this.domainScores = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeAuditsCompanion.insert({
    required String auditId,
    required String userId,
    required String domainScores,
    required DateTime timestamp,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : auditId = Value(auditId),
       userId = Value(userId),
       domainScores = Value(domainScores),
       timestamp = Value(timestamp);
  static Insertable<LifeAudit> custom({
    Expression<String>? auditId,
    Expression<String>? userId,
    Expression<String>? domainScores,
    Expression<DateTime>? timestamp,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (auditId != null) 'audit_id': auditId,
      if (userId != null) 'user_id': userId,
      if (domainScores != null) 'domain_scores': domainScores,
      if (timestamp != null) 'timestamp': timestamp,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeAuditsCompanion copyWith({
    Value<String>? auditId,
    Value<String>? userId,
    Value<String>? domainScores,
    Value<DateTime>? timestamp,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LifeAuditsCompanion(
      auditId: auditId ?? this.auditId,
      userId: userId ?? this.userId,
      domainScores: domainScores ?? this.domainScores,
      timestamp: timestamp ?? this.timestamp,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (auditId.present) {
      map['audit_id'] = Variable<String>(auditId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (domainScores.present) {
      map['domain_scores'] = Variable<String>(domainScores.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeAuditsCompanion(')
          ..write('auditId: $auditId, ')
          ..write('userId: $userId, ')
          ..write('domainScores: $domainScores, ')
          ..write('timestamp: $timestamp, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeeklyPulsesTable extends WeeklyPulses
    with TableInfo<$WeeklyPulsesTable, WeeklyPulse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyPulsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pulseIdMeta = const VerificationMeta(
    'pulseId',
  );
  @override
  late final GeneratedColumn<String> pulseId = GeneratedColumn<String>(
    'pulse_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainTagMeta = const VerificationMeta(
    'domainTag',
  );
  @override
  late final GeneratedColumn<String> domainTag = GeneratedColumn<String>(
    'domain_tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    check: () => ComparableExpr(score).isBetweenValues(1, 10),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reflectionTextMeta = const VerificationMeta(
    'reflectionText',
  );
  @override
  late final GeneratedColumn<String> reflectionText = GeneratedColumn<String>(
    'reflection_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weekStartDateMeta = const VerificationMeta(
    'weekStartDate',
  );
  @override
  late final GeneratedColumn<DateTime> weekStartDate =
      GeneratedColumn<DateTime>(
        'week_start_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    pulseId,
    userId,
    domainTag,
    score,
    reflectionText,
    weekStartDate,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_pulses';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklyPulse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pulse_id')) {
      context.handle(
        _pulseIdMeta,
        pulseId.isAcceptableOrUnknown(data['pulse_id']!, _pulseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pulseIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('domain_tag')) {
      context.handle(
        _domainTagMeta,
        domainTag.isAcceptableOrUnknown(data['domain_tag']!, _domainTagMeta),
      );
    } else if (isInserting) {
      context.missing(_domainTagMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('reflection_text')) {
      context.handle(
        _reflectionTextMeta,
        reflectionText.isAcceptableOrUnknown(
          data['reflection_text']!,
          _reflectionTextMeta,
        ),
      );
    }
    if (data.containsKey('week_start_date')) {
      context.handle(
        _weekStartDateMeta,
        weekStartDate.isAcceptableOrUnknown(
          data['week_start_date']!,
          _weekStartDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weekStartDateMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pulseId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, domainTag, weekStartDate},
  ];
  @override
  WeeklyPulse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyPulse(
      pulseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pulse_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      domainTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain_tag'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      reflectionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection_text'],
      ),
      weekStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}week_start_date'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $WeeklyPulsesTable createAlias(String alias) {
    return $WeeklyPulsesTable(attachedDatabase, alias);
  }
}

class WeeklyPulse extends DataClass implements Insertable<WeeklyPulse> {
  final String pulseId;
  final String userId;
  final String domainTag;
  final int score;
  final String? reflectionText;
  final DateTime weekStartDate;
  final DateTime? deletedAt;
  const WeeklyPulse({
    required this.pulseId,
    required this.userId,
    required this.domainTag,
    required this.score,
    this.reflectionText,
    required this.weekStartDate,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pulse_id'] = Variable<String>(pulseId);
    map['user_id'] = Variable<String>(userId);
    map['domain_tag'] = Variable<String>(domainTag);
    map['score'] = Variable<int>(score);
    if (!nullToAbsent || reflectionText != null) {
      map['reflection_text'] = Variable<String>(reflectionText);
    }
    map['week_start_date'] = Variable<DateTime>(weekStartDate);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  WeeklyPulsesCompanion toCompanion(bool nullToAbsent) {
    return WeeklyPulsesCompanion(
      pulseId: Value(pulseId),
      userId: Value(userId),
      domainTag: Value(domainTag),
      score: Value(score),
      reflectionText: reflectionText == null && nullToAbsent
          ? const Value.absent()
          : Value(reflectionText),
      weekStartDate: Value(weekStartDate),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory WeeklyPulse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyPulse(
      pulseId: serializer.fromJson<String>(json['pulseId']),
      userId: serializer.fromJson<String>(json['userId']),
      domainTag: serializer.fromJson<String>(json['domainTag']),
      score: serializer.fromJson<int>(json['score']),
      reflectionText: serializer.fromJson<String?>(json['reflectionText']),
      weekStartDate: serializer.fromJson<DateTime>(json['weekStartDate']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pulseId': serializer.toJson<String>(pulseId),
      'userId': serializer.toJson<String>(userId),
      'domainTag': serializer.toJson<String>(domainTag),
      'score': serializer.toJson<int>(score),
      'reflectionText': serializer.toJson<String?>(reflectionText),
      'weekStartDate': serializer.toJson<DateTime>(weekStartDate),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  WeeklyPulse copyWith({
    String? pulseId,
    String? userId,
    String? domainTag,
    int? score,
    Value<String?> reflectionText = const Value.absent(),
    DateTime? weekStartDate,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => WeeklyPulse(
    pulseId: pulseId ?? this.pulseId,
    userId: userId ?? this.userId,
    domainTag: domainTag ?? this.domainTag,
    score: score ?? this.score,
    reflectionText: reflectionText.present
        ? reflectionText.value
        : this.reflectionText,
    weekStartDate: weekStartDate ?? this.weekStartDate,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  WeeklyPulse copyWithCompanion(WeeklyPulsesCompanion data) {
    return WeeklyPulse(
      pulseId: data.pulseId.present ? data.pulseId.value : this.pulseId,
      userId: data.userId.present ? data.userId.value : this.userId,
      domainTag: data.domainTag.present ? data.domainTag.value : this.domainTag,
      score: data.score.present ? data.score.value : this.score,
      reflectionText: data.reflectionText.present
          ? data.reflectionText.value
          : this.reflectionText,
      weekStartDate: data.weekStartDate.present
          ? data.weekStartDate.value
          : this.weekStartDate,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyPulse(')
          ..write('pulseId: $pulseId, ')
          ..write('userId: $userId, ')
          ..write('domainTag: $domainTag, ')
          ..write('score: $score, ')
          ..write('reflectionText: $reflectionText, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    pulseId,
    userId,
    domainTag,
    score,
    reflectionText,
    weekStartDate,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyPulse &&
          other.pulseId == this.pulseId &&
          other.userId == this.userId &&
          other.domainTag == this.domainTag &&
          other.score == this.score &&
          other.reflectionText == this.reflectionText &&
          other.weekStartDate == this.weekStartDate &&
          other.deletedAt == this.deletedAt);
}

class WeeklyPulsesCompanion extends UpdateCompanion<WeeklyPulse> {
  final Value<String> pulseId;
  final Value<String> userId;
  final Value<String> domainTag;
  final Value<int> score;
  final Value<String?> reflectionText;
  final Value<DateTime> weekStartDate;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const WeeklyPulsesCompanion({
    this.pulseId = const Value.absent(),
    this.userId = const Value.absent(),
    this.domainTag = const Value.absent(),
    this.score = const Value.absent(),
    this.reflectionText = const Value.absent(),
    this.weekStartDate = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeeklyPulsesCompanion.insert({
    required String pulseId,
    required String userId,
    required String domainTag,
    required int score,
    this.reflectionText = const Value.absent(),
    required DateTime weekStartDate,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pulseId = Value(pulseId),
       userId = Value(userId),
       domainTag = Value(domainTag),
       score = Value(score),
       weekStartDate = Value(weekStartDate);
  static Insertable<WeeklyPulse> custom({
    Expression<String>? pulseId,
    Expression<String>? userId,
    Expression<String>? domainTag,
    Expression<int>? score,
    Expression<String>? reflectionText,
    Expression<DateTime>? weekStartDate,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pulseId != null) 'pulse_id': pulseId,
      if (userId != null) 'user_id': userId,
      if (domainTag != null) 'domain_tag': domainTag,
      if (score != null) 'score': score,
      if (reflectionText != null) 'reflection_text': reflectionText,
      if (weekStartDate != null) 'week_start_date': weekStartDate,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeeklyPulsesCompanion copyWith({
    Value<String>? pulseId,
    Value<String>? userId,
    Value<String>? domainTag,
    Value<int>? score,
    Value<String?>? reflectionText,
    Value<DateTime>? weekStartDate,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return WeeklyPulsesCompanion(
      pulseId: pulseId ?? this.pulseId,
      userId: userId ?? this.userId,
      domainTag: domainTag ?? this.domainTag,
      score: score ?? this.score,
      reflectionText: reflectionText ?? this.reflectionText,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pulseId.present) {
      map['pulse_id'] = Variable<String>(pulseId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (domainTag.present) {
      map['domain_tag'] = Variable<String>(domainTag.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (reflectionText.present) {
      map['reflection_text'] = Variable<String>(reflectionText.value);
    }
    if (weekStartDate.present) {
      map['week_start_date'] = Variable<DateTime>(weekStartDate.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyPulsesCompanion(')
          ..write('pulseId: $pulseId, ')
          ..write('userId: $userId, ')
          ..write('domainTag: $domainTag, ')
          ..write('score: $score, ')
          ..write('reflectionText: $reflectionText, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainTagMeta = const VerificationMeta(
    'domainTag',
  );
  @override
  late final GeneratedColumn<String> domainTag = GeneratedColumn<String>(
    'domain_tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Active'),
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Daily'),
  );
  static const VerificationMeta _scheduledDaysMeta = const VerificationMeta(
    'scheduledDays',
  );
  @override
  late final GeneratedColumn<String> scheduledDays = GeneratedColumn<String>(
    'scheduled_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initiationFrictionMeta =
      const VerificationMeta('initiationFriction');
  @override
  late final GeneratedColumn<int> initiationFriction = GeneratedColumn<int>(
    'initiation_friction',
    aliasedName,
    false,
    check: () => ComparableExpr(initiationFriction).isBetweenValues(1, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _originalFrictionMeta = const VerificationMeta(
    'originalFriction',
  );
  @override
  late final GeneratedColumn<int> originalFriction = GeneratedColumn<int>(
    'original_friction',
    aliasedName,
    false,
    check: () => ComparableExpr(originalFriction).isBetweenValues(1, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _energyCostMeta = const VerificationMeta(
    'energyCost',
  );
  @override
  late final GeneratedColumn<int> energyCost = GeneratedColumn<int>(
    'energy_cost',
    aliasedName,
    false,
    check: () => ComparableExpr(energyCost).isBetweenValues(1, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _impactScoreMeta = const VerificationMeta(
    'impactScore',
  );
  @override
  late final GeneratedColumn<int> impactScore = GeneratedColumn<int>(
    'impact_score',
    aliasedName,
    false,
    check: () => ComparableExpr(impactScore).isBetweenValues(1, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _lifetimeDoneCountMeta = const VerificationMeta(
    'lifetimeDoneCount',
  );
  @override
  late final GeneratedColumn<int> lifetimeDoneCount = GeneratedColumn<int>(
    'lifetime_done_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _weightedDoneScoreMeta = const VerificationMeta(
    'weightedDoneScore',
  );
  @override
  late final GeneratedColumn<double> weightedDoneScore =
      GeneratedColumn<double>(
        'weighted_done_score',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _completionRate90dMeta = const VerificationMeta(
    'completionRate90d',
  );
  @override
  late final GeneratedColumn<double> completionRate90d =
      GeneratedColumn<double>(
        'completion_rate90d',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastDecayEvaluatedAtMeta =
      const VerificationMeta('lastDecayEvaluatedAt');
  @override
  late final GeneratedColumn<DateTime> lastDecayEvaluatedAt =
      GeneratedColumn<DateTime>(
        'last_decay_evaluated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _mvaDurationMinMeta = const VerificationMeta(
    'mvaDurationMin',
  );
  @override
  late final GeneratedColumn<int> mvaDurationMin = GeneratedColumn<int>(
    'mva_duration_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _stackedToHabitIdMeta = const VerificationMeta(
    'stackedToHabitId',
  );
  @override
  late final GeneratedColumn<String> stackedToHabitId = GeneratedColumn<String>(
    'stacked_to_habit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalTagMeta = const VerificationMeta(
    'goalTag',
  );
  @override
  late final GeneratedColumn<String> goalTag = GeneratedColumn<String>(
    'goal_tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    habitId,
    userId,
    domainTag,
    title,
    status,
    archivedAt,
    frequency,
    scheduledDays,
    initiationFriction,
    originalFriction,
    energyCost,
    impactScore,
    lifetimeDoneCount,
    weightedDoneScore,
    completionRate90d,
    lastDecayEvaluatedAt,
    mvaDurationMin,
    stackedToHabitId,
    createdAt,
    deletedAt,
    goalTag,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('domain_tag')) {
      context.handle(
        _domainTagMeta,
        domainTag.isAcceptableOrUnknown(data['domain_tag']!, _domainTagMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('scheduled_days')) {
      context.handle(
        _scheduledDaysMeta,
        scheduledDays.isAcceptableOrUnknown(
          data['scheduled_days']!,
          _scheduledDaysMeta,
        ),
      );
    }
    if (data.containsKey('initiation_friction')) {
      context.handle(
        _initiationFrictionMeta,
        initiationFriction.isAcceptableOrUnknown(
          data['initiation_friction']!,
          _initiationFrictionMeta,
        ),
      );
    }
    if (data.containsKey('original_friction')) {
      context.handle(
        _originalFrictionMeta,
        originalFriction.isAcceptableOrUnknown(
          data['original_friction']!,
          _originalFrictionMeta,
        ),
      );
    }
    if (data.containsKey('energy_cost')) {
      context.handle(
        _energyCostMeta,
        energyCost.isAcceptableOrUnknown(data['energy_cost']!, _energyCostMeta),
      );
    }
    if (data.containsKey('impact_score')) {
      context.handle(
        _impactScoreMeta,
        impactScore.isAcceptableOrUnknown(
          data['impact_score']!,
          _impactScoreMeta,
        ),
      );
    }
    if (data.containsKey('lifetime_done_count')) {
      context.handle(
        _lifetimeDoneCountMeta,
        lifetimeDoneCount.isAcceptableOrUnknown(
          data['lifetime_done_count']!,
          _lifetimeDoneCountMeta,
        ),
      );
    }
    if (data.containsKey('weighted_done_score')) {
      context.handle(
        _weightedDoneScoreMeta,
        weightedDoneScore.isAcceptableOrUnknown(
          data['weighted_done_score']!,
          _weightedDoneScoreMeta,
        ),
      );
    }
    if (data.containsKey('completion_rate90d')) {
      context.handle(
        _completionRate90dMeta,
        completionRate90d.isAcceptableOrUnknown(
          data['completion_rate90d']!,
          _completionRate90dMeta,
        ),
      );
    }
    if (data.containsKey('last_decay_evaluated_at')) {
      context.handle(
        _lastDecayEvaluatedAtMeta,
        lastDecayEvaluatedAt.isAcceptableOrUnknown(
          data['last_decay_evaluated_at']!,
          _lastDecayEvaluatedAtMeta,
        ),
      );
    }
    if (data.containsKey('mva_duration_min')) {
      context.handle(
        _mvaDurationMinMeta,
        mvaDurationMin.isAcceptableOrUnknown(
          data['mva_duration_min']!,
          _mvaDurationMinMeta,
        ),
      );
    }
    if (data.containsKey('stacked_to_habit_id')) {
      context.handle(
        _stackedToHabitIdMeta,
        stackedToHabitId.isAcceptableOrUnknown(
          data['stacked_to_habit_id']!,
          _stackedToHabitIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('goal_tag')) {
      context.handle(
        _goalTagMeta,
        goalTag.isAcceptableOrUnknown(data['goal_tag']!, _goalTagMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitId};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      domainTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain_tag'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      scheduledDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheduled_days'],
      ),
      initiationFriction: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initiation_friction'],
      )!,
      originalFriction: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_friction'],
      )!,
      energyCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy_cost'],
      )!,
      impactScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}impact_score'],
      )!,
      lifetimeDoneCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lifetime_done_count'],
      )!,
      weightedDoneScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weighted_done_score'],
      )!,
      completionRate90d: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}completion_rate90d'],
      ),
      lastDecayEvaluatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_decay_evaluated_at'],
      ),
      mvaDurationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mva_duration_min'],
      )!,
      stackedToHabitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stacked_to_habit_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      goalTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_tag'],
      ),
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final String habitId;
  final String userId;
  final String? domainTag;
  final String title;
  final String status;
  final DateTime? archivedAt;
  final String frequency;
  final String? scheduledDays;
  final int initiationFriction;
  final int originalFriction;
  final int energyCost;
  final int impactScore;
  final int lifetimeDoneCount;
  final double weightedDoneScore;
  final double? completionRate90d;
  final DateTime? lastDecayEvaluatedAt;
  final int mvaDurationMin;
  final String? stackedToHabitId;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final String? goalTag;
  const Habit({
    required this.habitId,
    required this.userId,
    this.domainTag,
    required this.title,
    required this.status,
    this.archivedAt,
    required this.frequency,
    this.scheduledDays,
    required this.initiationFriction,
    required this.originalFriction,
    required this.energyCost,
    required this.impactScore,
    required this.lifetimeDoneCount,
    required this.weightedDoneScore,
    this.completionRate90d,
    this.lastDecayEvaluatedAt,
    required this.mvaDurationMin,
    this.stackedToHabitId,
    required this.createdAt,
    this.deletedAt,
    this.goalTag,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<String>(habitId);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || domainTag != null) {
      map['domain_tag'] = Variable<String>(domainTag);
    }
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || scheduledDays != null) {
      map['scheduled_days'] = Variable<String>(scheduledDays);
    }
    map['initiation_friction'] = Variable<int>(initiationFriction);
    map['original_friction'] = Variable<int>(originalFriction);
    map['energy_cost'] = Variable<int>(energyCost);
    map['impact_score'] = Variable<int>(impactScore);
    map['lifetime_done_count'] = Variable<int>(lifetimeDoneCount);
    map['weighted_done_score'] = Variable<double>(weightedDoneScore);
    if (!nullToAbsent || completionRate90d != null) {
      map['completion_rate90d'] = Variable<double>(completionRate90d);
    }
    if (!nullToAbsent || lastDecayEvaluatedAt != null) {
      map['last_decay_evaluated_at'] = Variable<DateTime>(lastDecayEvaluatedAt);
    }
    map['mva_duration_min'] = Variable<int>(mvaDurationMin);
    if (!nullToAbsent || stackedToHabitId != null) {
      map['stacked_to_habit_id'] = Variable<String>(stackedToHabitId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || goalTag != null) {
      map['goal_tag'] = Variable<String>(goalTag);
    }
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      habitId: Value(habitId),
      userId: Value(userId),
      domainTag: domainTag == null && nullToAbsent
          ? const Value.absent()
          : Value(domainTag),
      title: Value(title),
      status: Value(status),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      frequency: Value(frequency),
      scheduledDays: scheduledDays == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledDays),
      initiationFriction: Value(initiationFriction),
      originalFriction: Value(originalFriction),
      energyCost: Value(energyCost),
      impactScore: Value(impactScore),
      lifetimeDoneCount: Value(lifetimeDoneCount),
      weightedDoneScore: Value(weightedDoneScore),
      completionRate90d: completionRate90d == null && nullToAbsent
          ? const Value.absent()
          : Value(completionRate90d),
      lastDecayEvaluatedAt: lastDecayEvaluatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDecayEvaluatedAt),
      mvaDurationMin: Value(mvaDurationMin),
      stackedToHabitId: stackedToHabitId == null && nullToAbsent
          ? const Value.absent()
          : Value(stackedToHabitId),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      goalTag: goalTag == null && nullToAbsent
          ? const Value.absent()
          : Value(goalTag),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      habitId: serializer.fromJson<String>(json['habitId']),
      userId: serializer.fromJson<String>(json['userId']),
      domainTag: serializer.fromJson<String?>(json['domainTag']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      frequency: serializer.fromJson<String>(json['frequency']),
      scheduledDays: serializer.fromJson<String?>(json['scheduledDays']),
      initiationFriction: serializer.fromJson<int>(json['initiationFriction']),
      originalFriction: serializer.fromJson<int>(json['originalFriction']),
      energyCost: serializer.fromJson<int>(json['energyCost']),
      impactScore: serializer.fromJson<int>(json['impactScore']),
      lifetimeDoneCount: serializer.fromJson<int>(json['lifetimeDoneCount']),
      weightedDoneScore: serializer.fromJson<double>(json['weightedDoneScore']),
      completionRate90d: serializer.fromJson<double?>(
        json['completionRate90d'],
      ),
      lastDecayEvaluatedAt: serializer.fromJson<DateTime?>(
        json['lastDecayEvaluatedAt'],
      ),
      mvaDurationMin: serializer.fromJson<int>(json['mvaDurationMin']),
      stackedToHabitId: serializer.fromJson<String?>(json['stackedToHabitId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      goalTag: serializer.fromJson<String?>(json['goalTag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitId': serializer.toJson<String>(habitId),
      'userId': serializer.toJson<String>(userId),
      'domainTag': serializer.toJson<String?>(domainTag),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(status),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'frequency': serializer.toJson<String>(frequency),
      'scheduledDays': serializer.toJson<String?>(scheduledDays),
      'initiationFriction': serializer.toJson<int>(initiationFriction),
      'originalFriction': serializer.toJson<int>(originalFriction),
      'energyCost': serializer.toJson<int>(energyCost),
      'impactScore': serializer.toJson<int>(impactScore),
      'lifetimeDoneCount': serializer.toJson<int>(lifetimeDoneCount),
      'weightedDoneScore': serializer.toJson<double>(weightedDoneScore),
      'completionRate90d': serializer.toJson<double?>(completionRate90d),
      'lastDecayEvaluatedAt': serializer.toJson<DateTime?>(
        lastDecayEvaluatedAt,
      ),
      'mvaDurationMin': serializer.toJson<int>(mvaDurationMin),
      'stackedToHabitId': serializer.toJson<String?>(stackedToHabitId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'goalTag': serializer.toJson<String?>(goalTag),
    };
  }

  Habit copyWith({
    String? habitId,
    String? userId,
    Value<String?> domainTag = const Value.absent(),
    String? title,
    String? status,
    Value<DateTime?> archivedAt = const Value.absent(),
    String? frequency,
    Value<String?> scheduledDays = const Value.absent(),
    int? initiationFriction,
    int? originalFriction,
    int? energyCost,
    int? impactScore,
    int? lifetimeDoneCount,
    double? weightedDoneScore,
    Value<double?> completionRate90d = const Value.absent(),
    Value<DateTime?> lastDecayEvaluatedAt = const Value.absent(),
    int? mvaDurationMin,
    Value<String?> stackedToHabitId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> goalTag = const Value.absent(),
  }) => Habit(
    habitId: habitId ?? this.habitId,
    userId: userId ?? this.userId,
    domainTag: domainTag.present ? domainTag.value : this.domainTag,
    title: title ?? this.title,
    status: status ?? this.status,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    frequency: frequency ?? this.frequency,
    scheduledDays: scheduledDays.present
        ? scheduledDays.value
        : this.scheduledDays,
    initiationFriction: initiationFriction ?? this.initiationFriction,
    originalFriction: originalFriction ?? this.originalFriction,
    energyCost: energyCost ?? this.energyCost,
    impactScore: impactScore ?? this.impactScore,
    lifetimeDoneCount: lifetimeDoneCount ?? this.lifetimeDoneCount,
    weightedDoneScore: weightedDoneScore ?? this.weightedDoneScore,
    completionRate90d: completionRate90d.present
        ? completionRate90d.value
        : this.completionRate90d,
    lastDecayEvaluatedAt: lastDecayEvaluatedAt.present
        ? lastDecayEvaluatedAt.value
        : this.lastDecayEvaluatedAt,
    mvaDurationMin: mvaDurationMin ?? this.mvaDurationMin,
    stackedToHabitId: stackedToHabitId.present
        ? stackedToHabitId.value
        : this.stackedToHabitId,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    goalTag: goalTag.present ? goalTag.value : this.goalTag,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      userId: data.userId.present ? data.userId.value : this.userId,
      domainTag: data.domainTag.present ? data.domainTag.value : this.domainTag,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      initiationFriction: data.initiationFriction.present
          ? data.initiationFriction.value
          : this.initiationFriction,
      originalFriction: data.originalFriction.present
          ? data.originalFriction.value
          : this.originalFriction,
      energyCost: data.energyCost.present
          ? data.energyCost.value
          : this.energyCost,
      impactScore: data.impactScore.present
          ? data.impactScore.value
          : this.impactScore,
      lifetimeDoneCount: data.lifetimeDoneCount.present
          ? data.lifetimeDoneCount.value
          : this.lifetimeDoneCount,
      weightedDoneScore: data.weightedDoneScore.present
          ? data.weightedDoneScore.value
          : this.weightedDoneScore,
      completionRate90d: data.completionRate90d.present
          ? data.completionRate90d.value
          : this.completionRate90d,
      lastDecayEvaluatedAt: data.lastDecayEvaluatedAt.present
          ? data.lastDecayEvaluatedAt.value
          : this.lastDecayEvaluatedAt,
      mvaDurationMin: data.mvaDurationMin.present
          ? data.mvaDurationMin.value
          : this.mvaDurationMin,
      stackedToHabitId: data.stackedToHabitId.present
          ? data.stackedToHabitId.value
          : this.stackedToHabitId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      goalTag: data.goalTag.present ? data.goalTag.value : this.goalTag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('habitId: $habitId, ')
          ..write('userId: $userId, ')
          ..write('domainTag: $domainTag, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('frequency: $frequency, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('initiationFriction: $initiationFriction, ')
          ..write('originalFriction: $originalFriction, ')
          ..write('energyCost: $energyCost, ')
          ..write('impactScore: $impactScore, ')
          ..write('lifetimeDoneCount: $lifetimeDoneCount, ')
          ..write('weightedDoneScore: $weightedDoneScore, ')
          ..write('completionRate90d: $completionRate90d, ')
          ..write('lastDecayEvaluatedAt: $lastDecayEvaluatedAt, ')
          ..write('mvaDurationMin: $mvaDurationMin, ')
          ..write('stackedToHabitId: $stackedToHabitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('goalTag: $goalTag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    habitId,
    userId,
    domainTag,
    title,
    status,
    archivedAt,
    frequency,
    scheduledDays,
    initiationFriction,
    originalFriction,
    energyCost,
    impactScore,
    lifetimeDoneCount,
    weightedDoneScore,
    completionRate90d,
    lastDecayEvaluatedAt,
    mvaDurationMin,
    stackedToHabitId,
    createdAt,
    deletedAt,
    goalTag,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.habitId == this.habitId &&
          other.userId == this.userId &&
          other.domainTag == this.domainTag &&
          other.title == this.title &&
          other.status == this.status &&
          other.archivedAt == this.archivedAt &&
          other.frequency == this.frequency &&
          other.scheduledDays == this.scheduledDays &&
          other.initiationFriction == this.initiationFriction &&
          other.originalFriction == this.originalFriction &&
          other.energyCost == this.energyCost &&
          other.impactScore == this.impactScore &&
          other.lifetimeDoneCount == this.lifetimeDoneCount &&
          other.weightedDoneScore == this.weightedDoneScore &&
          other.completionRate90d == this.completionRate90d &&
          other.lastDecayEvaluatedAt == this.lastDecayEvaluatedAt &&
          other.mvaDurationMin == this.mvaDurationMin &&
          other.stackedToHabitId == this.stackedToHabitId &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt &&
          other.goalTag == this.goalTag);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<String> habitId;
  final Value<String> userId;
  final Value<String?> domainTag;
  final Value<String> title;
  final Value<String> status;
  final Value<DateTime?> archivedAt;
  final Value<String> frequency;
  final Value<String?> scheduledDays;
  final Value<int> initiationFriction;
  final Value<int> originalFriction;
  final Value<int> energyCost;
  final Value<int> impactScore;
  final Value<int> lifetimeDoneCount;
  final Value<double> weightedDoneScore;
  final Value<double?> completionRate90d;
  final Value<DateTime?> lastDecayEvaluatedAt;
  final Value<int> mvaDurationMin;
  final Value<String?> stackedToHabitId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> goalTag;
  final Value<int> rowid;
  const HabitsCompanion({
    this.habitId = const Value.absent(),
    this.userId = const Value.absent(),
    this.domainTag = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.frequency = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.initiationFriction = const Value.absent(),
    this.originalFriction = const Value.absent(),
    this.energyCost = const Value.absent(),
    this.impactScore = const Value.absent(),
    this.lifetimeDoneCount = const Value.absent(),
    this.weightedDoneScore = const Value.absent(),
    this.completionRate90d = const Value.absent(),
    this.lastDecayEvaluatedAt = const Value.absent(),
    this.mvaDurationMin = const Value.absent(),
    this.stackedToHabitId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.goalTag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String habitId,
    required String userId,
    this.domainTag = const Value.absent(),
    required String title,
    this.status = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.frequency = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.initiationFriction = const Value.absent(),
    this.originalFriction = const Value.absent(),
    this.energyCost = const Value.absent(),
    this.impactScore = const Value.absent(),
    this.lifetimeDoneCount = const Value.absent(),
    this.weightedDoneScore = const Value.absent(),
    this.completionRate90d = const Value.absent(),
    this.lastDecayEvaluatedAt = const Value.absent(),
    this.mvaDurationMin = const Value.absent(),
    this.stackedToHabitId = const Value.absent(),
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.goalTag = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : habitId = Value(habitId),
       userId = Value(userId),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<Habit> custom({
    Expression<String>? habitId,
    Expression<String>? userId,
    Expression<String>? domainTag,
    Expression<String>? title,
    Expression<String>? status,
    Expression<DateTime>? archivedAt,
    Expression<String>? frequency,
    Expression<String>? scheduledDays,
    Expression<int>? initiationFriction,
    Expression<int>? originalFriction,
    Expression<int>? energyCost,
    Expression<int>? impactScore,
    Expression<int>? lifetimeDoneCount,
    Expression<double>? weightedDoneScore,
    Expression<double>? completionRate90d,
    Expression<DateTime>? lastDecayEvaluatedAt,
    Expression<int>? mvaDurationMin,
    Expression<String>? stackedToHabitId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? goalTag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitId != null) 'habit_id': habitId,
      if (userId != null) 'user_id': userId,
      if (domainTag != null) 'domain_tag': domainTag,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (frequency != null) 'frequency': frequency,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (initiationFriction != null) 'initiation_friction': initiationFriction,
      if (originalFriction != null) 'original_friction': originalFriction,
      if (energyCost != null) 'energy_cost': energyCost,
      if (impactScore != null) 'impact_score': impactScore,
      if (lifetimeDoneCount != null) 'lifetime_done_count': lifetimeDoneCount,
      if (weightedDoneScore != null) 'weighted_done_score': weightedDoneScore,
      if (completionRate90d != null) 'completion_rate90d': completionRate90d,
      if (lastDecayEvaluatedAt != null)
        'last_decay_evaluated_at': lastDecayEvaluatedAt,
      if (mvaDurationMin != null) 'mva_duration_min': mvaDurationMin,
      if (stackedToHabitId != null) 'stacked_to_habit_id': stackedToHabitId,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (goalTag != null) 'goal_tag': goalTag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith({
    Value<String>? habitId,
    Value<String>? userId,
    Value<String?>? domainTag,
    Value<String>? title,
    Value<String>? status,
    Value<DateTime?>? archivedAt,
    Value<String>? frequency,
    Value<String?>? scheduledDays,
    Value<int>? initiationFriction,
    Value<int>? originalFriction,
    Value<int>? energyCost,
    Value<int>? impactScore,
    Value<int>? lifetimeDoneCount,
    Value<double>? weightedDoneScore,
    Value<double?>? completionRate90d,
    Value<DateTime?>? lastDecayEvaluatedAt,
    Value<int>? mvaDurationMin,
    Value<String?>? stackedToHabitId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? goalTag,
    Value<int>? rowid,
  }) {
    return HabitsCompanion(
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      domainTag: domainTag ?? this.domainTag,
      title: title ?? this.title,
      status: status ?? this.status,
      archivedAt: archivedAt ?? this.archivedAt,
      frequency: frequency ?? this.frequency,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      initiationFriction: initiationFriction ?? this.initiationFriction,
      originalFriction: originalFriction ?? this.originalFriction,
      energyCost: energyCost ?? this.energyCost,
      impactScore: impactScore ?? this.impactScore,
      lifetimeDoneCount: lifetimeDoneCount ?? this.lifetimeDoneCount,
      weightedDoneScore: weightedDoneScore ?? this.weightedDoneScore,
      completionRate90d: completionRate90d ?? this.completionRate90d,
      lastDecayEvaluatedAt: lastDecayEvaluatedAt ?? this.lastDecayEvaluatedAt,
      mvaDurationMin: mvaDurationMin ?? this.mvaDurationMin,
      stackedToHabitId: stackedToHabitId ?? this.stackedToHabitId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      goalTag: goalTag ?? this.goalTag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (domainTag.present) {
      map['domain_tag'] = Variable<String>(domainTag.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (scheduledDays.present) {
      map['scheduled_days'] = Variable<String>(scheduledDays.value);
    }
    if (initiationFriction.present) {
      map['initiation_friction'] = Variable<int>(initiationFriction.value);
    }
    if (originalFriction.present) {
      map['original_friction'] = Variable<int>(originalFriction.value);
    }
    if (energyCost.present) {
      map['energy_cost'] = Variable<int>(energyCost.value);
    }
    if (impactScore.present) {
      map['impact_score'] = Variable<int>(impactScore.value);
    }
    if (lifetimeDoneCount.present) {
      map['lifetime_done_count'] = Variable<int>(lifetimeDoneCount.value);
    }
    if (weightedDoneScore.present) {
      map['weighted_done_score'] = Variable<double>(weightedDoneScore.value);
    }
    if (completionRate90d.present) {
      map['completion_rate90d'] = Variable<double>(completionRate90d.value);
    }
    if (lastDecayEvaluatedAt.present) {
      map['last_decay_evaluated_at'] = Variable<DateTime>(
        lastDecayEvaluatedAt.value,
      );
    }
    if (mvaDurationMin.present) {
      map['mva_duration_min'] = Variable<int>(mvaDurationMin.value);
    }
    if (stackedToHabitId.present) {
      map['stacked_to_habit_id'] = Variable<String>(stackedToHabitId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (goalTag.present) {
      map['goal_tag'] = Variable<String>(goalTag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('habitId: $habitId, ')
          ..write('userId: $userId, ')
          ..write('domainTag: $domainTag, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('frequency: $frequency, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('initiationFriction: $initiationFriction, ')
          ..write('originalFriction: $originalFriction, ')
          ..write('energyCost: $energyCost, ')
          ..write('impactScore: $impactScore, ')
          ..write('lifetimeDoneCount: $lifetimeDoneCount, ')
          ..write('weightedDoneScore: $weightedDoneScore, ')
          ..write('completionRate90d: $completionRate90d, ')
          ..write('lastDecayEvaluatedAt: $lastDecayEvaluatedAt, ')
          ..write('mvaDurationMin: $mvaDurationMin, ')
          ..write('stackedToHabitId: $stackedToHabitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('goalTag: $goalTag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitLogsTable extends HabitLogs
    with TableInfo<$HabitLogsTable, HabitLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _logIdMeta = const VerificationMeta('logId');
  @override
  late final GeneratedColumn<String> logId = GeneratedColumn<String>(
    'log_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frictionReasonSelectedMeta =
      const VerificationMeta('frictionReasonSelected');
  @override
  late final GeneratedColumn<String> frictionReasonSelected =
      GeneratedColumn<String>(
        'friction_reason_selected',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _durationTargetMinMeta = const VerificationMeta(
    'durationTargetMin',
  );
  @override
  late final GeneratedColumn<int> durationTargetMin = GeneratedColumn<int>(
    'duration_target_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationActualMinMeta = const VerificationMeta(
    'durationActualMin',
  );
  @override
  late final GeneratedColumn<int> durationActualMin = GeneratedColumn<int>(
    'duration_actual_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    logId,
    habitId,
    date,
    status,
    frictionReasonSelected,
    durationTargetMin,
    durationActualMin,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('log_id')) {
      context.handle(
        _logIdMeta,
        logId.isAcceptableOrUnknown(data['log_id']!, _logIdMeta),
      );
    } else if (isInserting) {
      context.missing(_logIdMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('friction_reason_selected')) {
      context.handle(
        _frictionReasonSelectedMeta,
        frictionReasonSelected.isAcceptableOrUnknown(
          data['friction_reason_selected']!,
          _frictionReasonSelectedMeta,
        ),
      );
    }
    if (data.containsKey('duration_target_min')) {
      context.handle(
        _durationTargetMinMeta,
        durationTargetMin.isAcceptableOrUnknown(
          data['duration_target_min']!,
          _durationTargetMinMeta,
        ),
      );
    }
    if (data.containsKey('duration_actual_min')) {
      context.handle(
        _durationActualMinMeta,
        durationActualMin.isAcceptableOrUnknown(
          data['duration_actual_min']!,
          _durationActualMinMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {logId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {habitId, date},
  ];
  @override
  HabitLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitLog(
      logId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      frictionReasonSelected: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}friction_reason_selected'],
      ),
      durationTargetMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_target_min'],
      ),
      durationActualMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_actual_min'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $HabitLogsTable createAlias(String alias) {
    return $HabitLogsTable(attachedDatabase, alias);
  }
}

class HabitLog extends DataClass implements Insertable<HabitLog> {
  final String logId;
  final String habitId;
  final DateTime date;
  final String status;
  final String? frictionReasonSelected;
  final int? durationTargetMin;
  final int? durationActualMin;
  final DateTime? deletedAt;
  const HabitLog({
    required this.logId,
    required this.habitId,
    required this.date,
    required this.status,
    this.frictionReasonSelected,
    this.durationTargetMin,
    this.durationActualMin,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['log_id'] = Variable<String>(logId);
    map['habit_id'] = Variable<String>(habitId);
    map['date'] = Variable<DateTime>(date);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || frictionReasonSelected != null) {
      map['friction_reason_selected'] = Variable<String>(
        frictionReasonSelected,
      );
    }
    if (!nullToAbsent || durationTargetMin != null) {
      map['duration_target_min'] = Variable<int>(durationTargetMin);
    }
    if (!nullToAbsent || durationActualMin != null) {
      map['duration_actual_min'] = Variable<int>(durationActualMin);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  HabitLogsCompanion toCompanion(bool nullToAbsent) {
    return HabitLogsCompanion(
      logId: Value(logId),
      habitId: Value(habitId),
      date: Value(date),
      status: Value(status),
      frictionReasonSelected: frictionReasonSelected == null && nullToAbsent
          ? const Value.absent()
          : Value(frictionReasonSelected),
      durationTargetMin: durationTargetMin == null && nullToAbsent
          ? const Value.absent()
          : Value(durationTargetMin),
      durationActualMin: durationActualMin == null && nullToAbsent
          ? const Value.absent()
          : Value(durationActualMin),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory HabitLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitLog(
      logId: serializer.fromJson<String>(json['logId']),
      habitId: serializer.fromJson<String>(json['habitId']),
      date: serializer.fromJson<DateTime>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      frictionReasonSelected: serializer.fromJson<String?>(
        json['frictionReasonSelected'],
      ),
      durationTargetMin: serializer.fromJson<int?>(json['durationTargetMin']),
      durationActualMin: serializer.fromJson<int?>(json['durationActualMin']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'logId': serializer.toJson<String>(logId),
      'habitId': serializer.toJson<String>(habitId),
      'date': serializer.toJson<DateTime>(date),
      'status': serializer.toJson<String>(status),
      'frictionReasonSelected': serializer.toJson<String?>(
        frictionReasonSelected,
      ),
      'durationTargetMin': serializer.toJson<int?>(durationTargetMin),
      'durationActualMin': serializer.toJson<int?>(durationActualMin),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  HabitLog copyWith({
    String? logId,
    String? habitId,
    DateTime? date,
    String? status,
    Value<String?> frictionReasonSelected = const Value.absent(),
    Value<int?> durationTargetMin = const Value.absent(),
    Value<int?> durationActualMin = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => HabitLog(
    logId: logId ?? this.logId,
    habitId: habitId ?? this.habitId,
    date: date ?? this.date,
    status: status ?? this.status,
    frictionReasonSelected: frictionReasonSelected.present
        ? frictionReasonSelected.value
        : this.frictionReasonSelected,
    durationTargetMin: durationTargetMin.present
        ? durationTargetMin.value
        : this.durationTargetMin,
    durationActualMin: durationActualMin.present
        ? durationActualMin.value
        : this.durationActualMin,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  HabitLog copyWithCompanion(HabitLogsCompanion data) {
    return HabitLog(
      logId: data.logId.present ? data.logId.value : this.logId,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      frictionReasonSelected: data.frictionReasonSelected.present
          ? data.frictionReasonSelected.value
          : this.frictionReasonSelected,
      durationTargetMin: data.durationTargetMin.present
          ? data.durationTargetMin.value
          : this.durationTargetMin,
      durationActualMin: data.durationActualMin.present
          ? data.durationActualMin.value
          : this.durationActualMin,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitLog(')
          ..write('logId: $logId, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('frictionReasonSelected: $frictionReasonSelected, ')
          ..write('durationTargetMin: $durationTargetMin, ')
          ..write('durationActualMin: $durationActualMin, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    logId,
    habitId,
    date,
    status,
    frictionReasonSelected,
    durationTargetMin,
    durationActualMin,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitLog &&
          other.logId == this.logId &&
          other.habitId == this.habitId &&
          other.date == this.date &&
          other.status == this.status &&
          other.frictionReasonSelected == this.frictionReasonSelected &&
          other.durationTargetMin == this.durationTargetMin &&
          other.durationActualMin == this.durationActualMin &&
          other.deletedAt == this.deletedAt);
}

class HabitLogsCompanion extends UpdateCompanion<HabitLog> {
  final Value<String> logId;
  final Value<String> habitId;
  final Value<DateTime> date;
  final Value<String> status;
  final Value<String?> frictionReasonSelected;
  final Value<int?> durationTargetMin;
  final Value<int?> durationActualMin;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const HabitLogsCompanion({
    this.logId = const Value.absent(),
    this.habitId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.frictionReasonSelected = const Value.absent(),
    this.durationTargetMin = const Value.absent(),
    this.durationActualMin = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitLogsCompanion.insert({
    required String logId,
    required String habitId,
    required DateTime date,
    required String status,
    this.frictionReasonSelected = const Value.absent(),
    this.durationTargetMin = const Value.absent(),
    this.durationActualMin = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : logId = Value(logId),
       habitId = Value(habitId),
       date = Value(date),
       status = Value(status);
  static Insertable<HabitLog> custom({
    Expression<String>? logId,
    Expression<String>? habitId,
    Expression<DateTime>? date,
    Expression<String>? status,
    Expression<String>? frictionReasonSelected,
    Expression<int>? durationTargetMin,
    Expression<int>? durationActualMin,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (logId != null) 'log_id': logId,
      if (habitId != null) 'habit_id': habitId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (frictionReasonSelected != null)
        'friction_reason_selected': frictionReasonSelected,
      if (durationTargetMin != null) 'duration_target_min': durationTargetMin,
      if (durationActualMin != null) 'duration_actual_min': durationActualMin,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitLogsCompanion copyWith({
    Value<String>? logId,
    Value<String>? habitId,
    Value<DateTime>? date,
    Value<String>? status,
    Value<String?>? frictionReasonSelected,
    Value<int?>? durationTargetMin,
    Value<int?>? durationActualMin,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return HabitLogsCompanion(
      logId: logId ?? this.logId,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      status: status ?? this.status,
      frictionReasonSelected:
          frictionReasonSelected ?? this.frictionReasonSelected,
      durationTargetMin: durationTargetMin ?? this.durationTargetMin,
      durationActualMin: durationActualMin ?? this.durationActualMin,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (logId.present) {
      map['log_id'] = Variable<String>(logId.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (frictionReasonSelected.present) {
      map['friction_reason_selected'] = Variable<String>(
        frictionReasonSelected.value,
      );
    }
    if (durationTargetMin.present) {
      map['duration_target_min'] = Variable<int>(durationTargetMin.value);
    }
    if (durationActualMin.present) {
      map['duration_actual_min'] = Variable<int>(durationActualMin.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogsCompanion(')
          ..write('logId: $logId, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('frictionReasonSelected: $frictionReasonSelected, ')
          ..write('durationTargetMin: $durationTargetMin, ')
          ..write('durationActualMin: $durationActualMin, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodScoreMeta = const VerificationMeta(
    'moodScore',
  );
  @override
  late final GeneratedColumn<int> moodScore = GeneratedColumn<int>(
    'mood_score',
    aliasedName,
    false,
    check: () => ComparableExpr(moodScore).isBetweenValues(1, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keywordMeta = const VerificationMeta(
    'keyword',
  );
  @override
  late final GeneratedColumn<String> keyword = GeneratedColumn<String>(
    'keyword',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gratitudeTextMeta = const VerificationMeta(
    'gratitudeText',
  );
  @override
  late final GeneratedColumn<String> gratitudeText = GeneratedColumn<String>(
    'gratitude_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Lite'),
  );
  static const VerificationMeta _conflictCopyMeta = const VerificationMeta(
    'conflictCopy',
  );
  @override
  late final GeneratedColumn<String> conflictCopy = GeneratedColumn<String>(
    'conflict_copy',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entryId,
    userId,
    date,
    moodScore,
    keyword,
    textContent,
    gratitudeText,
    entryType,
    conflictCopy,
    deletedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('mood_score')) {
      context.handle(
        _moodScoreMeta,
        moodScore.isAcceptableOrUnknown(data['mood_score']!, _moodScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_moodScoreMeta);
    }
    if (data.containsKey('keyword')) {
      context.handle(
        _keywordMeta,
        keyword.isAcceptableOrUnknown(data['keyword']!, _keywordMeta),
      );
    }
    if (data.containsKey('text_content')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(
          data['text_content']!,
          _textContentMeta,
        ),
      );
    }
    if (data.containsKey('gratitude_text')) {
      context.handle(
        _gratitudeTextMeta,
        gratitudeText.isAcceptableOrUnknown(
          data['gratitude_text']!,
          _gratitudeTextMeta,
        ),
      );
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    }
    if (data.containsKey('conflict_copy')) {
      context.handle(
        _conflictCopyMeta,
        conflictCopy.isAcceptableOrUnknown(
          data['conflict_copy']!,
          _conflictCopyMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, date, entryType},
  ];
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      moodScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood_score'],
      )!,
      keyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keyword'],
      ),
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_content'],
      ),
      gratitudeText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gratitude_text'],
      ),
      entryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_type'],
      )!,
      conflictCopy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_copy'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  final String entryId;
  final String userId;
  final DateTime date;
  final int moodScore;
  final String? keyword;
  final String? textContent;
  final String? gratitudeText;
  final String entryType;
  final String? conflictCopy;
  final DateTime? deletedAt;
  final DateTime createdAt;
  const JournalEntry({
    required this.entryId,
    required this.userId,
    required this.date,
    required this.moodScore,
    this.keyword,
    this.textContent,
    this.gratitudeText,
    required this.entryType,
    this.conflictCopy,
    this.deletedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['mood_score'] = Variable<int>(moodScore);
    if (!nullToAbsent || keyword != null) {
      map['keyword'] = Variable<String>(keyword);
    }
    if (!nullToAbsent || textContent != null) {
      map['text_content'] = Variable<String>(textContent);
    }
    if (!nullToAbsent || gratitudeText != null) {
      map['gratitude_text'] = Variable<String>(gratitudeText);
    }
    map['entry_type'] = Variable<String>(entryType);
    if (!nullToAbsent || conflictCopy != null) {
      map['conflict_copy'] = Variable<String>(conflictCopy);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      entryId: Value(entryId),
      userId: Value(userId),
      date: Value(date),
      moodScore: Value(moodScore),
      keyword: keyword == null && nullToAbsent
          ? const Value.absent()
          : Value(keyword),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      gratitudeText: gratitudeText == null && nullToAbsent
          ? const Value.absent()
          : Value(gratitudeText),
      entryType: Value(entryType),
      conflictCopy: conflictCopy == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictCopy),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
    );
  }

  factory JournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      entryId: serializer.fromJson<String>(json['entryId']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      moodScore: serializer.fromJson<int>(json['moodScore']),
      keyword: serializer.fromJson<String?>(json['keyword']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      gratitudeText: serializer.fromJson<String?>(json['gratitudeText']),
      entryType: serializer.fromJson<String>(json['entryType']),
      conflictCopy: serializer.fromJson<String?>(json['conflictCopy']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'moodScore': serializer.toJson<int>(moodScore),
      'keyword': serializer.toJson<String?>(keyword),
      'textContent': serializer.toJson<String?>(textContent),
      'gratitudeText': serializer.toJson<String?>(gratitudeText),
      'entryType': serializer.toJson<String>(entryType),
      'conflictCopy': serializer.toJson<String?>(conflictCopy),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  JournalEntry copyWith({
    String? entryId,
    String? userId,
    DateTime? date,
    int? moodScore,
    Value<String?> keyword = const Value.absent(),
    Value<String?> textContent = const Value.absent(),
    Value<String?> gratitudeText = const Value.absent(),
    String? entryType,
    Value<String?> conflictCopy = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    DateTime? createdAt,
  }) => JournalEntry(
    entryId: entryId ?? this.entryId,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    moodScore: moodScore ?? this.moodScore,
    keyword: keyword.present ? keyword.value : this.keyword,
    textContent: textContent.present ? textContent.value : this.textContent,
    gratitudeText: gratitudeText.present
        ? gratitudeText.value
        : this.gratitudeText,
    entryType: entryType ?? this.entryType,
    conflictCopy: conflictCopy.present ? conflictCopy.value : this.conflictCopy,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      moodScore: data.moodScore.present ? data.moodScore.value : this.moodScore,
      keyword: data.keyword.present ? data.keyword.value : this.keyword,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      gratitudeText: data.gratitudeText.present
          ? data.gratitudeText.value
          : this.gratitudeText,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      conflictCopy: data.conflictCopy.present
          ? data.conflictCopy.value
          : this.conflictCopy,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('entryId: $entryId, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('moodScore: $moodScore, ')
          ..write('keyword: $keyword, ')
          ..write('textContent: $textContent, ')
          ..write('gratitudeText: $gratitudeText, ')
          ..write('entryType: $entryType, ')
          ..write('conflictCopy: $conflictCopy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entryId,
    userId,
    date,
    moodScore,
    keyword,
    textContent,
    gratitudeText,
    entryType,
    conflictCopy,
    deletedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.entryId == this.entryId &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.moodScore == this.moodScore &&
          other.keyword == this.keyword &&
          other.textContent == this.textContent &&
          other.gratitudeText == this.gratitudeText &&
          other.entryType == this.entryType &&
          other.conflictCopy == this.conflictCopy &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<String> entryId;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<int> moodScore;
  final Value<String?> keyword;
  final Value<String?> textContent;
  final Value<String?> gratitudeText;
  final Value<String> entryType;
  final Value<String?> conflictCopy;
  final Value<DateTime?> deletedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.entryId = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.moodScore = const Value.absent(),
    this.keyword = const Value.absent(),
    this.textContent = const Value.absent(),
    this.gratitudeText = const Value.absent(),
    this.entryType = const Value.absent(),
    this.conflictCopy = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    required String entryId,
    required String userId,
    required DateTime date,
    required int moodScore,
    this.keyword = const Value.absent(),
    this.textContent = const Value.absent(),
    this.gratitudeText = const Value.absent(),
    this.entryType = const Value.absent(),
    this.conflictCopy = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       userId = Value(userId),
       date = Value(date),
       moodScore = Value(moodScore),
       createdAt = Value(createdAt);
  static Insertable<JournalEntry> custom({
    Expression<String>? entryId,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<int>? moodScore,
    Expression<String>? keyword,
    Expression<String>? textContent,
    Expression<String>? gratitudeText,
    Expression<String>? entryType,
    Expression<String>? conflictCopy,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (moodScore != null) 'mood_score': moodScore,
      if (keyword != null) 'keyword': keyword,
      if (textContent != null) 'text_content': textContent,
      if (gratitudeText != null) 'gratitude_text': gratitudeText,
      if (entryType != null) 'entry_type': entryType,
      if (conflictCopy != null) 'conflict_copy': conflictCopy,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<String>? entryId,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<int>? moodScore,
    Value<String?>? keyword,
    Value<String?>? textContent,
    Value<String?>? gratitudeText,
    Value<String>? entryType,
    Value<String?>? conflictCopy,
    Value<DateTime?>? deletedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      entryId: entryId ?? this.entryId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      moodScore: moodScore ?? this.moodScore,
      keyword: keyword ?? this.keyword,
      textContent: textContent ?? this.textContent,
      gratitudeText: gratitudeText ?? this.gratitudeText,
      entryType: entryType ?? this.entryType,
      conflictCopy: conflictCopy ?? this.conflictCopy,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (moodScore.present) {
      map['mood_score'] = Variable<int>(moodScore.value);
    }
    if (keyword.present) {
      map['keyword'] = Variable<String>(keyword.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (gratitudeText.present) {
      map['gratitude_text'] = Variable<String>(gratitudeText.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (conflictCopy.present) {
      map['conflict_copy'] = Variable<String>(conflictCopy.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('entryId: $entryId, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('moodScore: $moodScore, ')
          ..write('keyword: $keyword, ')
          ..write('textContent: $textContent, ')
          ..write('gratitudeText: $gratitudeText, ')
          ..write('entryType: $entryType, ')
          ..write('conflictCopy: $conflictCopy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThinkingCanvasSessionsTable extends ThinkingCanvasSessions
    with TableInfo<$ThinkingCanvasSessionsTable, ThinkingCanvasSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThinkingCanvasSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodKeyMeta = const VerificationMeta(
    'methodKey',
  );
  @override
  late final GeneratedColumn<String> methodKey = GeneratedColumn<String>(
    'method_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawNotesMeta = const VerificationMeta(
    'rawNotes',
  );
  @override
  late final GeneratedColumn<String> rawNotes = GeneratedColumn<String>(
    'raw_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryTextMeta = const VerificationMeta(
    'summaryText',
  );
  @override
  late final GeneratedColumn<String> summaryText = GeneratedColumn<String>(
    'summary_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paperSessionMeta = const VerificationMeta(
    'paperSession',
  );
  @override
  late final GeneratedColumn<bool> paperSession = GeneratedColumn<bool>(
    'paper_session',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paper_session" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _paperArtifactRefMeta = const VerificationMeta(
    'paperArtifactRef',
  );
  @override
  late final GeneratedColumn<String> paperArtifactRef = GeneratedColumn<String>(
    'paper_artifact_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _structuredOutputMeta = const VerificationMeta(
    'structuredOutput',
  );
  @override
  late final GeneratedColumn<String> structuredOutput = GeneratedColumn<String>(
    'structured_output',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextActionMeta = const VerificationMeta(
    'nextAction',
  );
  @override
  late final GeneratedColumn<String> nextAction = GeneratedColumn<String>(
    'next_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedHabitIdMeta = const VerificationMeta(
    'linkedHabitId',
  );
  @override
  late final GeneratedColumn<String> linkedHabitId = GeneratedColumn<String>(
    'linked_habit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    userId,
    methodKey,
    topic,
    rawNotes,
    summaryText,
    paperSession,
    paperArtifactRef,
    structuredOutput,
    nextAction,
    linkedHabitId,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'thinking_canvas_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThinkingCanvasSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('method_key')) {
      context.handle(
        _methodKeyMeta,
        methodKey.isAcceptableOrUnknown(data['method_key']!, _methodKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_methodKeyMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    }
    if (data.containsKey('raw_notes')) {
      context.handle(
        _rawNotesMeta,
        rawNotes.isAcceptableOrUnknown(data['raw_notes']!, _rawNotesMeta),
      );
    }
    if (data.containsKey('summary_text')) {
      context.handle(
        _summaryTextMeta,
        summaryText.isAcceptableOrUnknown(
          data['summary_text']!,
          _summaryTextMeta,
        ),
      );
    }
    if (data.containsKey('paper_session')) {
      context.handle(
        _paperSessionMeta,
        paperSession.isAcceptableOrUnknown(
          data['paper_session']!,
          _paperSessionMeta,
        ),
      );
    }
    if (data.containsKey('paper_artifact_ref')) {
      context.handle(
        _paperArtifactRefMeta,
        paperArtifactRef.isAcceptableOrUnknown(
          data['paper_artifact_ref']!,
          _paperArtifactRefMeta,
        ),
      );
    }
    if (data.containsKey('structured_output')) {
      context.handle(
        _structuredOutputMeta,
        structuredOutput.isAcceptableOrUnknown(
          data['structured_output']!,
          _structuredOutputMeta,
        ),
      );
    }
    if (data.containsKey('next_action')) {
      context.handle(
        _nextActionMeta,
        nextAction.isAcceptableOrUnknown(data['next_action']!, _nextActionMeta),
      );
    }
    if (data.containsKey('linked_habit_id')) {
      context.handle(
        _linkedHabitIdMeta,
        linkedHabitId.isAcceptableOrUnknown(
          data['linked_habit_id']!,
          _linkedHabitIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  ThinkingCanvasSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThinkingCanvasSession(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      methodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method_key'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      ),
      rawNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_notes'],
      ),
      summaryText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_text'],
      ),
      paperSession: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paper_session'],
      )!,
      paperArtifactRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paper_artifact_ref'],
      ),
      structuredOutput: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}structured_output'],
      ),
      nextAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_action'],
      ),
      linkedHabitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_habit_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ThinkingCanvasSessionsTable createAlias(String alias) {
    return $ThinkingCanvasSessionsTable(attachedDatabase, alias);
  }
}

class ThinkingCanvasSession extends DataClass
    implements Insertable<ThinkingCanvasSession> {
  final String sessionId;
  final String userId;
  final String methodKey;
  final String? topic;
  final String? rawNotes;
  final String? summaryText;
  final bool paperSession;
  final String? paperArtifactRef;
  final String? structuredOutput;
  final String? nextAction;
  final String? linkedHabitId;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const ThinkingCanvasSession({
    required this.sessionId,
    required this.userId,
    required this.methodKey,
    this.topic,
    this.rawNotes,
    this.summaryText,
    required this.paperSession,
    this.paperArtifactRef,
    this.structuredOutput,
    this.nextAction,
    this.linkedHabitId,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['user_id'] = Variable<String>(userId);
    map['method_key'] = Variable<String>(methodKey);
    if (!nullToAbsent || topic != null) {
      map['topic'] = Variable<String>(topic);
    }
    if (!nullToAbsent || rawNotes != null) {
      map['raw_notes'] = Variable<String>(rawNotes);
    }
    if (!nullToAbsent || summaryText != null) {
      map['summary_text'] = Variable<String>(summaryText);
    }
    map['paper_session'] = Variable<bool>(paperSession);
    if (!nullToAbsent || paperArtifactRef != null) {
      map['paper_artifact_ref'] = Variable<String>(paperArtifactRef);
    }
    if (!nullToAbsent || structuredOutput != null) {
      map['structured_output'] = Variable<String>(structuredOutput);
    }
    if (!nullToAbsent || nextAction != null) {
      map['next_action'] = Variable<String>(nextAction);
    }
    if (!nullToAbsent || linkedHabitId != null) {
      map['linked_habit_id'] = Variable<String>(linkedHabitId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ThinkingCanvasSessionsCompanion toCompanion(bool nullToAbsent) {
    return ThinkingCanvasSessionsCompanion(
      sessionId: Value(sessionId),
      userId: Value(userId),
      methodKey: Value(methodKey),
      topic: topic == null && nullToAbsent
          ? const Value.absent()
          : Value(topic),
      rawNotes: rawNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(rawNotes),
      summaryText: summaryText == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryText),
      paperSession: Value(paperSession),
      paperArtifactRef: paperArtifactRef == null && nullToAbsent
          ? const Value.absent()
          : Value(paperArtifactRef),
      structuredOutput: structuredOutput == null && nullToAbsent
          ? const Value.absent()
          : Value(structuredOutput),
      nextAction: nextAction == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAction),
      linkedHabitId: linkedHabitId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedHabitId),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ThinkingCanvasSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThinkingCanvasSession(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      userId: serializer.fromJson<String>(json['userId']),
      methodKey: serializer.fromJson<String>(json['methodKey']),
      topic: serializer.fromJson<String?>(json['topic']),
      rawNotes: serializer.fromJson<String?>(json['rawNotes']),
      summaryText: serializer.fromJson<String?>(json['summaryText']),
      paperSession: serializer.fromJson<bool>(json['paperSession']),
      paperArtifactRef: serializer.fromJson<String?>(json['paperArtifactRef']),
      structuredOutput: serializer.fromJson<String?>(json['structuredOutput']),
      nextAction: serializer.fromJson<String?>(json['nextAction']),
      linkedHabitId: serializer.fromJson<String?>(json['linkedHabitId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'userId': serializer.toJson<String>(userId),
      'methodKey': serializer.toJson<String>(methodKey),
      'topic': serializer.toJson<String?>(topic),
      'rawNotes': serializer.toJson<String?>(rawNotes),
      'summaryText': serializer.toJson<String?>(summaryText),
      'paperSession': serializer.toJson<bool>(paperSession),
      'paperArtifactRef': serializer.toJson<String?>(paperArtifactRef),
      'structuredOutput': serializer.toJson<String?>(structuredOutput),
      'nextAction': serializer.toJson<String?>(nextAction),
      'linkedHabitId': serializer.toJson<String?>(linkedHabitId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ThinkingCanvasSession copyWith({
    String? sessionId,
    String? userId,
    String? methodKey,
    Value<String?> topic = const Value.absent(),
    Value<String?> rawNotes = const Value.absent(),
    Value<String?> summaryText = const Value.absent(),
    bool? paperSession,
    Value<String?> paperArtifactRef = const Value.absent(),
    Value<String?> structuredOutput = const Value.absent(),
    Value<String?> nextAction = const Value.absent(),
    Value<String?> linkedHabitId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ThinkingCanvasSession(
    sessionId: sessionId ?? this.sessionId,
    userId: userId ?? this.userId,
    methodKey: methodKey ?? this.methodKey,
    topic: topic.present ? topic.value : this.topic,
    rawNotes: rawNotes.present ? rawNotes.value : this.rawNotes,
    summaryText: summaryText.present ? summaryText.value : this.summaryText,
    paperSession: paperSession ?? this.paperSession,
    paperArtifactRef: paperArtifactRef.present
        ? paperArtifactRef.value
        : this.paperArtifactRef,
    structuredOutput: structuredOutput.present
        ? structuredOutput.value
        : this.structuredOutput,
    nextAction: nextAction.present ? nextAction.value : this.nextAction,
    linkedHabitId: linkedHabitId.present
        ? linkedHabitId.value
        : this.linkedHabitId,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ThinkingCanvasSession copyWithCompanion(
    ThinkingCanvasSessionsCompanion data,
  ) {
    return ThinkingCanvasSession(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      userId: data.userId.present ? data.userId.value : this.userId,
      methodKey: data.methodKey.present ? data.methodKey.value : this.methodKey,
      topic: data.topic.present ? data.topic.value : this.topic,
      rawNotes: data.rawNotes.present ? data.rawNotes.value : this.rawNotes,
      summaryText: data.summaryText.present
          ? data.summaryText.value
          : this.summaryText,
      paperSession: data.paperSession.present
          ? data.paperSession.value
          : this.paperSession,
      paperArtifactRef: data.paperArtifactRef.present
          ? data.paperArtifactRef.value
          : this.paperArtifactRef,
      structuredOutput: data.structuredOutput.present
          ? data.structuredOutput.value
          : this.structuredOutput,
      nextAction: data.nextAction.present
          ? data.nextAction.value
          : this.nextAction,
      linkedHabitId: data.linkedHabitId.present
          ? data.linkedHabitId.value
          : this.linkedHabitId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThinkingCanvasSession(')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('methodKey: $methodKey, ')
          ..write('topic: $topic, ')
          ..write('rawNotes: $rawNotes, ')
          ..write('summaryText: $summaryText, ')
          ..write('paperSession: $paperSession, ')
          ..write('paperArtifactRef: $paperArtifactRef, ')
          ..write('structuredOutput: $structuredOutput, ')
          ..write('nextAction: $nextAction, ')
          ..write('linkedHabitId: $linkedHabitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    userId,
    methodKey,
    topic,
    rawNotes,
    summaryText,
    paperSession,
    paperArtifactRef,
    structuredOutput,
    nextAction,
    linkedHabitId,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThinkingCanvasSession &&
          other.sessionId == this.sessionId &&
          other.userId == this.userId &&
          other.methodKey == this.methodKey &&
          other.topic == this.topic &&
          other.rawNotes == this.rawNotes &&
          other.summaryText == this.summaryText &&
          other.paperSession == this.paperSession &&
          other.paperArtifactRef == this.paperArtifactRef &&
          other.structuredOutput == this.structuredOutput &&
          other.nextAction == this.nextAction &&
          other.linkedHabitId == this.linkedHabitId &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class ThinkingCanvasSessionsCompanion
    extends UpdateCompanion<ThinkingCanvasSession> {
  final Value<String> sessionId;
  final Value<String> userId;
  final Value<String> methodKey;
  final Value<String?> topic;
  final Value<String?> rawNotes;
  final Value<String?> summaryText;
  final Value<bool> paperSession;
  final Value<String?> paperArtifactRef;
  final Value<String?> structuredOutput;
  final Value<String?> nextAction;
  final Value<String?> linkedHabitId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ThinkingCanvasSessionsCompanion({
    this.sessionId = const Value.absent(),
    this.userId = const Value.absent(),
    this.methodKey = const Value.absent(),
    this.topic = const Value.absent(),
    this.rawNotes = const Value.absent(),
    this.summaryText = const Value.absent(),
    this.paperSession = const Value.absent(),
    this.paperArtifactRef = const Value.absent(),
    this.structuredOutput = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.linkedHabitId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThinkingCanvasSessionsCompanion.insert({
    required String sessionId,
    required String userId,
    required String methodKey,
    this.topic = const Value.absent(),
    this.rawNotes = const Value.absent(),
    this.summaryText = const Value.absent(),
    this.paperSession = const Value.absent(),
    this.paperArtifactRef = const Value.absent(),
    this.structuredOutput = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.linkedHabitId = const Value.absent(),
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       userId = Value(userId),
       methodKey = Value(methodKey),
       createdAt = Value(createdAt);
  static Insertable<ThinkingCanvasSession> custom({
    Expression<String>? sessionId,
    Expression<String>? userId,
    Expression<String>? methodKey,
    Expression<String>? topic,
    Expression<String>? rawNotes,
    Expression<String>? summaryText,
    Expression<bool>? paperSession,
    Expression<String>? paperArtifactRef,
    Expression<String>? structuredOutput,
    Expression<String>? nextAction,
    Expression<String>? linkedHabitId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (userId != null) 'user_id': userId,
      if (methodKey != null) 'method_key': methodKey,
      if (topic != null) 'topic': topic,
      if (rawNotes != null) 'raw_notes': rawNotes,
      if (summaryText != null) 'summary_text': summaryText,
      if (paperSession != null) 'paper_session': paperSession,
      if (paperArtifactRef != null) 'paper_artifact_ref': paperArtifactRef,
      if (structuredOutput != null) 'structured_output': structuredOutput,
      if (nextAction != null) 'next_action': nextAction,
      if (linkedHabitId != null) 'linked_habit_id': linkedHabitId,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThinkingCanvasSessionsCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? userId,
    Value<String>? methodKey,
    Value<String?>? topic,
    Value<String?>? rawNotes,
    Value<String?>? summaryText,
    Value<bool>? paperSession,
    Value<String?>? paperArtifactRef,
    Value<String?>? structuredOutput,
    Value<String?>? nextAction,
    Value<String?>? linkedHabitId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ThinkingCanvasSessionsCompanion(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      methodKey: methodKey ?? this.methodKey,
      topic: topic ?? this.topic,
      rawNotes: rawNotes ?? this.rawNotes,
      summaryText: summaryText ?? this.summaryText,
      paperSession: paperSession ?? this.paperSession,
      paperArtifactRef: paperArtifactRef ?? this.paperArtifactRef,
      structuredOutput: structuredOutput ?? this.structuredOutput,
      nextAction: nextAction ?? this.nextAction,
      linkedHabitId: linkedHabitId ?? this.linkedHabitId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (methodKey.present) {
      map['method_key'] = Variable<String>(methodKey.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (rawNotes.present) {
      map['raw_notes'] = Variable<String>(rawNotes.value);
    }
    if (summaryText.present) {
      map['summary_text'] = Variable<String>(summaryText.value);
    }
    if (paperSession.present) {
      map['paper_session'] = Variable<bool>(paperSession.value);
    }
    if (paperArtifactRef.present) {
      map['paper_artifact_ref'] = Variable<String>(paperArtifactRef.value);
    }
    if (structuredOutput.present) {
      map['structured_output'] = Variable<String>(structuredOutput.value);
    }
    if (nextAction.present) {
      map['next_action'] = Variable<String>(nextAction.value);
    }
    if (linkedHabitId.present) {
      map['linked_habit_id'] = Variable<String>(linkedHabitId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThinkingCanvasSessionsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('userId: $userId, ')
          ..write('methodKey: $methodKey, ')
          ..write('topic: $topic, ')
          ..write('rawNotes: $rawNotes, ')
          ..write('summaryText: $summaryText, ')
          ..write('paperSession: $paperSession, ')
          ..write('paperArtifactRef: $paperArtifactRef, ')
          ..write('structuredOutput: $structuredOutput, ')
          ..write('nextAction: $nextAction, ')
          ..write('linkedHabitId: $linkedHabitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConsentLogsTable extends ConsentLogs
    with TableInfo<$ConsentLogsTable, ConsentLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsentLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _consentIdMeta = const VerificationMeta(
    'consentId',
  );
  @override
  late final GeneratedColumn<String> consentId = GeneratedColumn<String>(
    'consent_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consentTypeMeta = const VerificationMeta(
    'consentType',
  );
  @override
  late final GeneratedColumn<String> consentType = GeneratedColumn<String>(
    'consent_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grantedAtMeta = const VerificationMeta(
    'grantedAt',
  );
  @override
  late final GeneratedColumn<DateTime> grantedAt = GeneratedColumn<DateTime>(
    'granted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revokedAtMeta = const VerificationMeta(
    'revokedAt',
  );
  @override
  late final GeneratedColumn<DateTime> revokedAt = GeneratedColumn<DateTime>(
    'revoked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    consentId,
    userId,
    consentType,
    grantedAt,
    version,
    revokedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consent_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConsentLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('consent_id')) {
      context.handle(
        _consentIdMeta,
        consentId.isAcceptableOrUnknown(data['consent_id']!, _consentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_consentIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('consent_type')) {
      context.handle(
        _consentTypeMeta,
        consentType.isAcceptableOrUnknown(
          data['consent_type']!,
          _consentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_consentTypeMeta);
    }
    if (data.containsKey('granted_at')) {
      context.handle(
        _grantedAtMeta,
        grantedAt.isAcceptableOrUnknown(data['granted_at']!, _grantedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_grantedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('revoked_at')) {
      context.handle(
        _revokedAtMeta,
        revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {consentId};
  @override
  ConsentLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConsentLog(
      consentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consent_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      consentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consent_type'],
      )!,
      grantedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}granted_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      revokedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}revoked_at'],
      ),
    );
  }

  @override
  $ConsentLogsTable createAlias(String alias) {
    return $ConsentLogsTable(attachedDatabase, alias);
  }
}

class ConsentLog extends DataClass implements Insertable<ConsentLog> {
  final String consentId;
  final String userId;
  final String consentType;
  final DateTime grantedAt;
  final String version;
  final DateTime? revokedAt;
  const ConsentLog({
    required this.consentId,
    required this.userId,
    required this.consentType,
    required this.grantedAt,
    required this.version,
    this.revokedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['consent_id'] = Variable<String>(consentId);
    map['user_id'] = Variable<String>(userId);
    map['consent_type'] = Variable<String>(consentType);
    map['granted_at'] = Variable<DateTime>(grantedAt);
    map['version'] = Variable<String>(version);
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<DateTime>(revokedAt);
    }
    return map;
  }

  ConsentLogsCompanion toCompanion(bool nullToAbsent) {
    return ConsentLogsCompanion(
      consentId: Value(consentId),
      userId: Value(userId),
      consentType: Value(consentType),
      grantedAt: Value(grantedAt),
      version: Value(version),
      revokedAt: revokedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAt),
    );
  }

  factory ConsentLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConsentLog(
      consentId: serializer.fromJson<String>(json['consentId']),
      userId: serializer.fromJson<String>(json['userId']),
      consentType: serializer.fromJson<String>(json['consentType']),
      grantedAt: serializer.fromJson<DateTime>(json['grantedAt']),
      version: serializer.fromJson<String>(json['version']),
      revokedAt: serializer.fromJson<DateTime?>(json['revokedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'consentId': serializer.toJson<String>(consentId),
      'userId': serializer.toJson<String>(userId),
      'consentType': serializer.toJson<String>(consentType),
      'grantedAt': serializer.toJson<DateTime>(grantedAt),
      'version': serializer.toJson<String>(version),
      'revokedAt': serializer.toJson<DateTime?>(revokedAt),
    };
  }

  ConsentLog copyWith({
    String? consentId,
    String? userId,
    String? consentType,
    DateTime? grantedAt,
    String? version,
    Value<DateTime?> revokedAt = const Value.absent(),
  }) => ConsentLog(
    consentId: consentId ?? this.consentId,
    userId: userId ?? this.userId,
    consentType: consentType ?? this.consentType,
    grantedAt: grantedAt ?? this.grantedAt,
    version: version ?? this.version,
    revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
  );
  ConsentLog copyWithCompanion(ConsentLogsCompanion data) {
    return ConsentLog(
      consentId: data.consentId.present ? data.consentId.value : this.consentId,
      userId: data.userId.present ? data.userId.value : this.userId,
      consentType: data.consentType.present
          ? data.consentType.value
          : this.consentType,
      grantedAt: data.grantedAt.present ? data.grantedAt.value : this.grantedAt,
      version: data.version.present ? data.version.value : this.version,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConsentLog(')
          ..write('consentId: $consentId, ')
          ..write('userId: $userId, ')
          ..write('consentType: $consentType, ')
          ..write('grantedAt: $grantedAt, ')
          ..write('version: $version, ')
          ..write('revokedAt: $revokedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    consentId,
    userId,
    consentType,
    grantedAt,
    version,
    revokedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsentLog &&
          other.consentId == this.consentId &&
          other.userId == this.userId &&
          other.consentType == this.consentType &&
          other.grantedAt == this.grantedAt &&
          other.version == this.version &&
          other.revokedAt == this.revokedAt);
}

class ConsentLogsCompanion extends UpdateCompanion<ConsentLog> {
  final Value<String> consentId;
  final Value<String> userId;
  final Value<String> consentType;
  final Value<DateTime> grantedAt;
  final Value<String> version;
  final Value<DateTime?> revokedAt;
  final Value<int> rowid;
  const ConsentLogsCompanion({
    this.consentId = const Value.absent(),
    this.userId = const Value.absent(),
    this.consentType = const Value.absent(),
    this.grantedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConsentLogsCompanion.insert({
    required String consentId,
    required String userId,
    required String consentType,
    required DateTime grantedAt,
    required String version,
    this.revokedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : consentId = Value(consentId),
       userId = Value(userId),
       consentType = Value(consentType),
       grantedAt = Value(grantedAt),
       version = Value(version);
  static Insertable<ConsentLog> custom({
    Expression<String>? consentId,
    Expression<String>? userId,
    Expression<String>? consentType,
    Expression<DateTime>? grantedAt,
    Expression<String>? version,
    Expression<DateTime>? revokedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (consentId != null) 'consent_id': consentId,
      if (userId != null) 'user_id': userId,
      if (consentType != null) 'consent_type': consentType,
      if (grantedAt != null) 'granted_at': grantedAt,
      if (version != null) 'version': version,
      if (revokedAt != null) 'revoked_at': revokedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConsentLogsCompanion copyWith({
    Value<String>? consentId,
    Value<String>? userId,
    Value<String>? consentType,
    Value<DateTime>? grantedAt,
    Value<String>? version,
    Value<DateTime?>? revokedAt,
    Value<int>? rowid,
  }) {
    return ConsentLogsCompanion(
      consentId: consentId ?? this.consentId,
      userId: userId ?? this.userId,
      consentType: consentType ?? this.consentType,
      grantedAt: grantedAt ?? this.grantedAt,
      version: version ?? this.version,
      revokedAt: revokedAt ?? this.revokedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (consentId.present) {
      map['consent_id'] = Variable<String>(consentId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (consentType.present) {
      map['consent_type'] = Variable<String>(consentType.value);
    }
    if (grantedAt.present) {
      map['granted_at'] = Variable<DateTime>(grantedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<DateTime>(revokedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsentLogsCompanion(')
          ..write('consentId: $consentId, ')
          ..write('userId: $userId, ')
          ..write('consentType: $consentType, ')
          ..write('grantedAt: $grantedAt, ')
          ..write('version: $version, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderPreferencesTable extends ReminderPreferences
    with TableInfo<$ReminderPreferencesTable, ReminderPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
    'reminder_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('08:00'),
  );
  static const VerificationMeta _quietHoursStartMeta = const VerificationMeta(
    'quietHoursStart',
  );
  @override
  late final GeneratedColumn<String> quietHoursStart = GeneratedColumn<String>(
    'quiet_hours_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('22:00'),
  );
  static const VerificationMeta _quietHoursEndMeta = const VerificationMeta(
    'quietHoursEnd',
  );
  @override
  late final GeneratedColumn<String> quietHoursEnd = GeneratedColumn<String>(
    'quiet_hours_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('07:00'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    habitId,
    reminderEnabled,
    reminderTime,
    quietHoursStart,
    quietHoursEnd,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('quiet_hours_start')) {
      context.handle(
        _quietHoursStartMeta,
        quietHoursStart.isAcceptableOrUnknown(
          data['quiet_hours_start']!,
          _quietHoursStartMeta,
        ),
      );
    }
    if (data.containsKey('quiet_hours_end')) {
      context.handle(
        _quietHoursEndMeta,
        quietHoursEnd.isAcceptableOrUnknown(
          data['quiet_hours_end']!,
          _quietHoursEndMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitId};
  @override
  ReminderPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderPreference(
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_time'],
      )!,
      quietHoursStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quiet_hours_start'],
      )!,
      quietHoursEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quiet_hours_end'],
      )!,
    );
  }

  @override
  $ReminderPreferencesTable createAlias(String alias) {
    return $ReminderPreferencesTable(attachedDatabase, alias);
  }
}

class ReminderPreference extends DataClass
    implements Insertable<ReminderPreference> {
  final String habitId;
  final bool reminderEnabled;
  final String reminderTime;
  final String quietHoursStart;
  final String quietHoursEnd;
  const ReminderPreference({
    required this.habitId,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.quietHoursStart,
    required this.quietHoursEnd,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<String>(habitId);
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['reminder_time'] = Variable<String>(reminderTime);
    map['quiet_hours_start'] = Variable<String>(quietHoursStart);
    map['quiet_hours_end'] = Variable<String>(quietHoursEnd);
    return map;
  }

  ReminderPreferencesCompanion toCompanion(bool nullToAbsent) {
    return ReminderPreferencesCompanion(
      habitId: Value(habitId),
      reminderEnabled: Value(reminderEnabled),
      reminderTime: Value(reminderTime),
      quietHoursStart: Value(quietHoursStart),
      quietHoursEnd: Value(quietHoursEnd),
    );
  }

  factory ReminderPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderPreference(
      habitId: serializer.fromJson<String>(json['habitId']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderTime: serializer.fromJson<String>(json['reminderTime']),
      quietHoursStart: serializer.fromJson<String>(json['quietHoursStart']),
      quietHoursEnd: serializer.fromJson<String>(json['quietHoursEnd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitId': serializer.toJson<String>(habitId),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderTime': serializer.toJson<String>(reminderTime),
      'quietHoursStart': serializer.toJson<String>(quietHoursStart),
      'quietHoursEnd': serializer.toJson<String>(quietHoursEnd),
    };
  }

  ReminderPreference copyWith({
    String? habitId,
    bool? reminderEnabled,
    String? reminderTime,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) => ReminderPreference(
    habitId: habitId ?? this.habitId,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderTime: reminderTime ?? this.reminderTime,
    quietHoursStart: quietHoursStart ?? this.quietHoursStart,
    quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
  );
  ReminderPreference copyWithCompanion(ReminderPreferencesCompanion data) {
    return ReminderPreference(
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      quietHoursStart: data.quietHoursStart.present
          ? data.quietHoursStart.value
          : this.quietHoursStart,
      quietHoursEnd: data.quietHoursEnd.present
          ? data.quietHoursEnd.value
          : this.quietHoursEnd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderPreference(')
          ..write('habitId: $habitId, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('quietHoursStart: $quietHoursStart, ')
          ..write('quietHoursEnd: $quietHoursEnd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    habitId,
    reminderEnabled,
    reminderTime,
    quietHoursStart,
    quietHoursEnd,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderPreference &&
          other.habitId == this.habitId &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderTime == this.reminderTime &&
          other.quietHoursStart == this.quietHoursStart &&
          other.quietHoursEnd == this.quietHoursEnd);
}

class ReminderPreferencesCompanion extends UpdateCompanion<ReminderPreference> {
  final Value<String> habitId;
  final Value<bool> reminderEnabled;
  final Value<String> reminderTime;
  final Value<String> quietHoursStart;
  final Value<String> quietHoursEnd;
  final Value<int> rowid;
  const ReminderPreferencesCompanion({
    this.habitId = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.quietHoursStart = const Value.absent(),
    this.quietHoursEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderPreferencesCompanion.insert({
    required String habitId,
    this.reminderEnabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.quietHoursStart = const Value.absent(),
    this.quietHoursEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : habitId = Value(habitId);
  static Insertable<ReminderPreference> custom({
    Expression<String>? habitId,
    Expression<bool>? reminderEnabled,
    Expression<String>? reminderTime,
    Expression<String>? quietHoursStart,
    Expression<String>? quietHoursEnd,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitId != null) 'habit_id': habitId,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (quietHoursStart != null) 'quiet_hours_start': quietHoursStart,
      if (quietHoursEnd != null) 'quiet_hours_end': quietHoursEnd,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderPreferencesCompanion copyWith({
    Value<String>? habitId,
    Value<bool>? reminderEnabled,
    Value<String>? reminderTime,
    Value<String>? quietHoursStart,
    Value<String>? quietHoursEnd,
    Value<int>? rowid,
  }) {
    return ReminderPreferencesCompanion(
      habitId: habitId ?? this.habitId,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (quietHoursStart.present) {
      map['quiet_hours_start'] = Variable<String>(quietHoursStart.value);
    }
    if (quietHoursEnd.present) {
      map['quiet_hours_end'] = Variable<String>(quietHoursEnd.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderPreferencesCompanion(')
          ..write('habitId: $habitId, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('quietHoursStart: $quietHoursStart, ')
          ..write('quietHoursEnd: $quietHoursEnd, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WellnessPromptLogsTable extends WellnessPromptLogs
    with TableInfo<$WellnessPromptLogsTable, WellnessPromptLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WellnessPromptLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _promptIdMeta = const VerificationMeta(
    'promptId',
  );
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
    'prompt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerTypeMeta = const VerificationMeta(
    'triggerType',
  );
  @override
  late final GeneratedColumn<String> triggerType = GeneratedColumn<String>(
    'trigger_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptedAtMeta = const VerificationMeta(
    'promptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> promptedAt = GeneratedColumn<DateTime>(
    'prompted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userActionMeta = const VerificationMeta(
    'userAction',
  );
  @override
  late final GeneratedColumn<String> userAction = GeneratedColumn<String>(
    'user_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    promptId,
    userId,
    triggerType,
    promptedAt,
    userAction,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wellness_prompt_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WellnessPromptLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('prompt_id')) {
      context.handle(
        _promptIdMeta,
        promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_promptIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('trigger_type')) {
      context.handle(
        _triggerTypeMeta,
        triggerType.isAcceptableOrUnknown(
          data['trigger_type']!,
          _triggerTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerTypeMeta);
    }
    if (data.containsKey('prompted_at')) {
      context.handle(
        _promptedAtMeta,
        promptedAt.isAcceptableOrUnknown(data['prompted_at']!, _promptedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_promptedAtMeta);
    }
    if (data.containsKey('user_action')) {
      context.handle(
        _userActionMeta,
        userAction.isAcceptableOrUnknown(data['user_action']!, _userActionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {promptId};
  @override
  WellnessPromptLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WellnessPromptLog(
      promptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      triggerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_type'],
      )!,
      promptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}prompted_at'],
      )!,
      userAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_action'],
      ),
    );
  }

  @override
  $WellnessPromptLogsTable createAlias(String alias) {
    return $WellnessPromptLogsTable(attachedDatabase, alias);
  }
}

class WellnessPromptLog extends DataClass
    implements Insertable<WellnessPromptLog> {
  final String promptId;
  final String userId;
  final String triggerType;
  final DateTime promptedAt;
  final String? userAction;
  const WellnessPromptLog({
    required this.promptId,
    required this.userId,
    required this.triggerType,
    required this.promptedAt,
    this.userAction,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['prompt_id'] = Variable<String>(promptId);
    map['user_id'] = Variable<String>(userId);
    map['trigger_type'] = Variable<String>(triggerType);
    map['prompted_at'] = Variable<DateTime>(promptedAt);
    if (!nullToAbsent || userAction != null) {
      map['user_action'] = Variable<String>(userAction);
    }
    return map;
  }

  WellnessPromptLogsCompanion toCompanion(bool nullToAbsent) {
    return WellnessPromptLogsCompanion(
      promptId: Value(promptId),
      userId: Value(userId),
      triggerType: Value(triggerType),
      promptedAt: Value(promptedAt),
      userAction: userAction == null && nullToAbsent
          ? const Value.absent()
          : Value(userAction),
    );
  }

  factory WellnessPromptLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WellnessPromptLog(
      promptId: serializer.fromJson<String>(json['promptId']),
      userId: serializer.fromJson<String>(json['userId']),
      triggerType: serializer.fromJson<String>(json['triggerType']),
      promptedAt: serializer.fromJson<DateTime>(json['promptedAt']),
      userAction: serializer.fromJson<String?>(json['userAction']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'promptId': serializer.toJson<String>(promptId),
      'userId': serializer.toJson<String>(userId),
      'triggerType': serializer.toJson<String>(triggerType),
      'promptedAt': serializer.toJson<DateTime>(promptedAt),
      'userAction': serializer.toJson<String?>(userAction),
    };
  }

  WellnessPromptLog copyWith({
    String? promptId,
    String? userId,
    String? triggerType,
    DateTime? promptedAt,
    Value<String?> userAction = const Value.absent(),
  }) => WellnessPromptLog(
    promptId: promptId ?? this.promptId,
    userId: userId ?? this.userId,
    triggerType: triggerType ?? this.triggerType,
    promptedAt: promptedAt ?? this.promptedAt,
    userAction: userAction.present ? userAction.value : this.userAction,
  );
  WellnessPromptLog copyWithCompanion(WellnessPromptLogsCompanion data) {
    return WellnessPromptLog(
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      userId: data.userId.present ? data.userId.value : this.userId,
      triggerType: data.triggerType.present
          ? data.triggerType.value
          : this.triggerType,
      promptedAt: data.promptedAt.present
          ? data.promptedAt.value
          : this.promptedAt,
      userAction: data.userAction.present
          ? data.userAction.value
          : this.userAction,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WellnessPromptLog(')
          ..write('promptId: $promptId, ')
          ..write('userId: $userId, ')
          ..write('triggerType: $triggerType, ')
          ..write('promptedAt: $promptedAt, ')
          ..write('userAction: $userAction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(promptId, userId, triggerType, promptedAt, userAction);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WellnessPromptLog &&
          other.promptId == this.promptId &&
          other.userId == this.userId &&
          other.triggerType == this.triggerType &&
          other.promptedAt == this.promptedAt &&
          other.userAction == this.userAction);
}

class WellnessPromptLogsCompanion extends UpdateCompanion<WellnessPromptLog> {
  final Value<String> promptId;
  final Value<String> userId;
  final Value<String> triggerType;
  final Value<DateTime> promptedAt;
  final Value<String?> userAction;
  final Value<int> rowid;
  const WellnessPromptLogsCompanion({
    this.promptId = const Value.absent(),
    this.userId = const Value.absent(),
    this.triggerType = const Value.absent(),
    this.promptedAt = const Value.absent(),
    this.userAction = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WellnessPromptLogsCompanion.insert({
    required String promptId,
    required String userId,
    required String triggerType,
    required DateTime promptedAt,
    this.userAction = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : promptId = Value(promptId),
       userId = Value(userId),
       triggerType = Value(triggerType),
       promptedAt = Value(promptedAt);
  static Insertable<WellnessPromptLog> custom({
    Expression<String>? promptId,
    Expression<String>? userId,
    Expression<String>? triggerType,
    Expression<DateTime>? promptedAt,
    Expression<String>? userAction,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (promptId != null) 'prompt_id': promptId,
      if (userId != null) 'user_id': userId,
      if (triggerType != null) 'trigger_type': triggerType,
      if (promptedAt != null) 'prompted_at': promptedAt,
      if (userAction != null) 'user_action': userAction,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WellnessPromptLogsCompanion copyWith({
    Value<String>? promptId,
    Value<String>? userId,
    Value<String>? triggerType,
    Value<DateTime>? promptedAt,
    Value<String?>? userAction,
    Value<int>? rowid,
  }) {
    return WellnessPromptLogsCompanion(
      promptId: promptId ?? this.promptId,
      userId: userId ?? this.userId,
      triggerType: triggerType ?? this.triggerType,
      promptedAt: promptedAt ?? this.promptedAt,
      userAction: userAction ?? this.userAction,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (triggerType.present) {
      map['trigger_type'] = Variable<String>(triggerType.value);
    }
    if (promptedAt.present) {
      map['prompted_at'] = Variable<DateTime>(promptedAt.value);
    }
    if (userAction.present) {
      map['user_action'] = Variable<String>(userAction.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WellnessPromptLogsCompanion(')
          ..write('promptId: $promptId, ')
          ..write('userId: $userId, ')
          ..write('triggerType: $triggerType, ')
          ..write('promptedAt: $promptedAt, ')
          ..write('userAction: $userAction, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecisionEntriesTable extends DecisionEntries
    with TableInfo<$DecisionEntriesTable, DecisionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecisionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _decisionIdMeta = const VerificationMeta(
    'decisionId',
  );
  @override
  late final GeneratedColumn<String> decisionId = GeneratedColumn<String>(
    'decision_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionsMeta = const VerificationMeta(
    'options',
  );
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
    'options',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assumptionsMeta = const VerificationMeta(
    'assumptions',
  );
  @override
  late final GeneratedColumn<String> assumptions = GeneratedColumn<String>(
    'assumptions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectationsMeta = const VerificationMeta(
    'expectations',
  );
  @override
  late final GeneratedColumn<String> expectations = GeneratedColumn<String>(
    'expectations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decisionDateMeta = const VerificationMeta(
    'decisionDate',
  );
  @override
  late final GeneratedColumn<DateTime> decisionDate = GeneratedColumn<DateTime>(
    'decision_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewDateMeta = const VerificationMeta(
    'reviewDate',
  );
  @override
  late final GeneratedColumn<DateTime> reviewDate = GeneratedColumn<DateTime>(
    'review_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReviewedMeta = const VerificationMeta(
    'isReviewed',
  );
  @override
  late final GeneratedColumn<bool> isReviewed = GeneratedColumn<bool>(
    'is_reviewed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_reviewed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reviewReflectionMeta = const VerificationMeta(
    'reviewReflection',
  );
  @override
  late final GeneratedColumn<String> reviewReflection = GeneratedColumn<String>(
    'review_reflection',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewPeriodDaysMeta = const VerificationMeta(
    'reviewPeriodDays',
  );
  @override
  late final GeneratedColumn<int> reviewPeriodDays = GeneratedColumn<int>(
    'review_period_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(90),
  );
  @override
  List<GeneratedColumn> get $columns => [
    decisionId,
    userId,
    title,
    description,
    options,
    assumptions,
    expectations,
    decisionDate,
    reviewDate,
    isReviewed,
    reviewReflection,
    deletedAt,
    reviewPeriodDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decision_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DecisionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('decision_id')) {
      context.handle(
        _decisionIdMeta,
        decisionId.isAcceptableOrUnknown(data['decision_id']!, _decisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_decisionIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('options')) {
      context.handle(
        _optionsMeta,
        options.isAcceptableOrUnknown(data['options']!, _optionsMeta),
      );
    } else if (isInserting) {
      context.missing(_optionsMeta);
    }
    if (data.containsKey('assumptions')) {
      context.handle(
        _assumptionsMeta,
        assumptions.isAcceptableOrUnknown(
          data['assumptions']!,
          _assumptionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assumptionsMeta);
    }
    if (data.containsKey('expectations')) {
      context.handle(
        _expectationsMeta,
        expectations.isAcceptableOrUnknown(
          data['expectations']!,
          _expectationsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectationsMeta);
    }
    if (data.containsKey('decision_date')) {
      context.handle(
        _decisionDateMeta,
        decisionDate.isAcceptableOrUnknown(
          data['decision_date']!,
          _decisionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_decisionDateMeta);
    }
    if (data.containsKey('review_date')) {
      context.handle(
        _reviewDateMeta,
        reviewDate.isAcceptableOrUnknown(data['review_date']!, _reviewDateMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewDateMeta);
    }
    if (data.containsKey('is_reviewed')) {
      context.handle(
        _isReviewedMeta,
        isReviewed.isAcceptableOrUnknown(data['is_reviewed']!, _isReviewedMeta),
      );
    }
    if (data.containsKey('review_reflection')) {
      context.handle(
        _reviewReflectionMeta,
        reviewReflection.isAcceptableOrUnknown(
          data['review_reflection']!,
          _reviewReflectionMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('review_period_days')) {
      context.handle(
        _reviewPeriodDaysMeta,
        reviewPeriodDays.isAcceptableOrUnknown(
          data['review_period_days']!,
          _reviewPeriodDaysMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {decisionId};
  @override
  DecisionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DecisionEntry(
      decisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      options: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options'],
      )!,
      assumptions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assumptions'],
      )!,
      expectations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expectations'],
      )!,
      decisionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}decision_date'],
      )!,
      reviewDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}review_date'],
      )!,
      isReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_reviewed'],
      )!,
      reviewReflection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_reflection'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      reviewPeriodDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_period_days'],
      )!,
    );
  }

  @override
  $DecisionEntriesTable createAlias(String alias) {
    return $DecisionEntriesTable(attachedDatabase, alias);
  }
}

class DecisionEntry extends DataClass implements Insertable<DecisionEntry> {
  final String decisionId;
  final String userId;
  final String title;
  final String description;
  final String options;
  final String assumptions;
  final String expectations;
  final DateTime decisionDate;
  final DateTime reviewDate;
  final bool isReviewed;
  final String? reviewReflection;
  final DateTime? deletedAt;
  final int reviewPeriodDays;
  const DecisionEntry({
    required this.decisionId,
    required this.userId,
    required this.title,
    required this.description,
    required this.options,
    required this.assumptions,
    required this.expectations,
    required this.decisionDate,
    required this.reviewDate,
    required this.isReviewed,
    this.reviewReflection,
    this.deletedAt,
    required this.reviewPeriodDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['decision_id'] = Variable<String>(decisionId);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['options'] = Variable<String>(options);
    map['assumptions'] = Variable<String>(assumptions);
    map['expectations'] = Variable<String>(expectations);
    map['decision_date'] = Variable<DateTime>(decisionDate);
    map['review_date'] = Variable<DateTime>(reviewDate);
    map['is_reviewed'] = Variable<bool>(isReviewed);
    if (!nullToAbsent || reviewReflection != null) {
      map['review_reflection'] = Variable<String>(reviewReflection);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['review_period_days'] = Variable<int>(reviewPeriodDays);
    return map;
  }

  DecisionEntriesCompanion toCompanion(bool nullToAbsent) {
    return DecisionEntriesCompanion(
      decisionId: Value(decisionId),
      userId: Value(userId),
      title: Value(title),
      description: Value(description),
      options: Value(options),
      assumptions: Value(assumptions),
      expectations: Value(expectations),
      decisionDate: Value(decisionDate),
      reviewDate: Value(reviewDate),
      isReviewed: Value(isReviewed),
      reviewReflection: reviewReflection == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewReflection),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      reviewPeriodDays: Value(reviewPeriodDays),
    );
  }

  factory DecisionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DecisionEntry(
      decisionId: serializer.fromJson<String>(json['decisionId']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      options: serializer.fromJson<String>(json['options']),
      assumptions: serializer.fromJson<String>(json['assumptions']),
      expectations: serializer.fromJson<String>(json['expectations']),
      decisionDate: serializer.fromJson<DateTime>(json['decisionDate']),
      reviewDate: serializer.fromJson<DateTime>(json['reviewDate']),
      isReviewed: serializer.fromJson<bool>(json['isReviewed']),
      reviewReflection: serializer.fromJson<String?>(json['reviewReflection']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      reviewPeriodDays: serializer.fromJson<int>(json['reviewPeriodDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'decisionId': serializer.toJson<String>(decisionId),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'options': serializer.toJson<String>(options),
      'assumptions': serializer.toJson<String>(assumptions),
      'expectations': serializer.toJson<String>(expectations),
      'decisionDate': serializer.toJson<DateTime>(decisionDate),
      'reviewDate': serializer.toJson<DateTime>(reviewDate),
      'isReviewed': serializer.toJson<bool>(isReviewed),
      'reviewReflection': serializer.toJson<String?>(reviewReflection),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'reviewPeriodDays': serializer.toJson<int>(reviewPeriodDays),
    };
  }

  DecisionEntry copyWith({
    String? decisionId,
    String? userId,
    String? title,
    String? description,
    String? options,
    String? assumptions,
    String? expectations,
    DateTime? decisionDate,
    DateTime? reviewDate,
    bool? isReviewed,
    Value<String?> reviewReflection = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    int? reviewPeriodDays,
  }) => DecisionEntry(
    decisionId: decisionId ?? this.decisionId,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description ?? this.description,
    options: options ?? this.options,
    assumptions: assumptions ?? this.assumptions,
    expectations: expectations ?? this.expectations,
    decisionDate: decisionDate ?? this.decisionDate,
    reviewDate: reviewDate ?? this.reviewDate,
    isReviewed: isReviewed ?? this.isReviewed,
    reviewReflection: reviewReflection.present
        ? reviewReflection.value
        : this.reviewReflection,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    reviewPeriodDays: reviewPeriodDays ?? this.reviewPeriodDays,
  );
  DecisionEntry copyWithCompanion(DecisionEntriesCompanion data) {
    return DecisionEntry(
      decisionId: data.decisionId.present
          ? data.decisionId.value
          : this.decisionId,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      options: data.options.present ? data.options.value : this.options,
      assumptions: data.assumptions.present
          ? data.assumptions.value
          : this.assumptions,
      expectations: data.expectations.present
          ? data.expectations.value
          : this.expectations,
      decisionDate: data.decisionDate.present
          ? data.decisionDate.value
          : this.decisionDate,
      reviewDate: data.reviewDate.present
          ? data.reviewDate.value
          : this.reviewDate,
      isReviewed: data.isReviewed.present
          ? data.isReviewed.value
          : this.isReviewed,
      reviewReflection: data.reviewReflection.present
          ? data.reviewReflection.value
          : this.reviewReflection,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      reviewPeriodDays: data.reviewPeriodDays.present
          ? data.reviewPeriodDays.value
          : this.reviewPeriodDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DecisionEntry(')
          ..write('decisionId: $decisionId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('options: $options, ')
          ..write('assumptions: $assumptions, ')
          ..write('expectations: $expectations, ')
          ..write('decisionDate: $decisionDate, ')
          ..write('reviewDate: $reviewDate, ')
          ..write('isReviewed: $isReviewed, ')
          ..write('reviewReflection: $reviewReflection, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('reviewPeriodDays: $reviewPeriodDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    decisionId,
    userId,
    title,
    description,
    options,
    assumptions,
    expectations,
    decisionDate,
    reviewDate,
    isReviewed,
    reviewReflection,
    deletedAt,
    reviewPeriodDays,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DecisionEntry &&
          other.decisionId == this.decisionId &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.options == this.options &&
          other.assumptions == this.assumptions &&
          other.expectations == this.expectations &&
          other.decisionDate == this.decisionDate &&
          other.reviewDate == this.reviewDate &&
          other.isReviewed == this.isReviewed &&
          other.reviewReflection == this.reviewReflection &&
          other.deletedAt == this.deletedAt &&
          other.reviewPeriodDays == this.reviewPeriodDays);
}

class DecisionEntriesCompanion extends UpdateCompanion<DecisionEntry> {
  final Value<String> decisionId;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> description;
  final Value<String> options;
  final Value<String> assumptions;
  final Value<String> expectations;
  final Value<DateTime> decisionDate;
  final Value<DateTime> reviewDate;
  final Value<bool> isReviewed;
  final Value<String?> reviewReflection;
  final Value<DateTime?> deletedAt;
  final Value<int> reviewPeriodDays;
  final Value<int> rowid;
  const DecisionEntriesCompanion({
    this.decisionId = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.options = const Value.absent(),
    this.assumptions = const Value.absent(),
    this.expectations = const Value.absent(),
    this.decisionDate = const Value.absent(),
    this.reviewDate = const Value.absent(),
    this.isReviewed = const Value.absent(),
    this.reviewReflection = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.reviewPeriodDays = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecisionEntriesCompanion.insert({
    required String decisionId,
    required String userId,
    required String title,
    required String description,
    required String options,
    required String assumptions,
    required String expectations,
    required DateTime decisionDate,
    required DateTime reviewDate,
    this.isReviewed = const Value.absent(),
    this.reviewReflection = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.reviewPeriodDays = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : decisionId = Value(decisionId),
       userId = Value(userId),
       title = Value(title),
       description = Value(description),
       options = Value(options),
       assumptions = Value(assumptions),
       expectations = Value(expectations),
       decisionDate = Value(decisionDate),
       reviewDate = Value(reviewDate);
  static Insertable<DecisionEntry> custom({
    Expression<String>? decisionId,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? options,
    Expression<String>? assumptions,
    Expression<String>? expectations,
    Expression<DateTime>? decisionDate,
    Expression<DateTime>? reviewDate,
    Expression<bool>? isReviewed,
    Expression<String>? reviewReflection,
    Expression<DateTime>? deletedAt,
    Expression<int>? reviewPeriodDays,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (decisionId != null) 'decision_id': decisionId,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (options != null) 'options': options,
      if (assumptions != null) 'assumptions': assumptions,
      if (expectations != null) 'expectations': expectations,
      if (decisionDate != null) 'decision_date': decisionDate,
      if (reviewDate != null) 'review_date': reviewDate,
      if (isReviewed != null) 'is_reviewed': isReviewed,
      if (reviewReflection != null) 'review_reflection': reviewReflection,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (reviewPeriodDays != null) 'review_period_days': reviewPeriodDays,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecisionEntriesCompanion copyWith({
    Value<String>? decisionId,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? description,
    Value<String>? options,
    Value<String>? assumptions,
    Value<String>? expectations,
    Value<DateTime>? decisionDate,
    Value<DateTime>? reviewDate,
    Value<bool>? isReviewed,
    Value<String?>? reviewReflection,
    Value<DateTime?>? deletedAt,
    Value<int>? reviewPeriodDays,
    Value<int>? rowid,
  }) {
    return DecisionEntriesCompanion(
      decisionId: decisionId ?? this.decisionId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      options: options ?? this.options,
      assumptions: assumptions ?? this.assumptions,
      expectations: expectations ?? this.expectations,
      decisionDate: decisionDate ?? this.decisionDate,
      reviewDate: reviewDate ?? this.reviewDate,
      isReviewed: isReviewed ?? this.isReviewed,
      reviewReflection: reviewReflection ?? this.reviewReflection,
      deletedAt: deletedAt ?? this.deletedAt,
      reviewPeriodDays: reviewPeriodDays ?? this.reviewPeriodDays,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (decisionId.present) {
      map['decision_id'] = Variable<String>(decisionId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (assumptions.present) {
      map['assumptions'] = Variable<String>(assumptions.value);
    }
    if (expectations.present) {
      map['expectations'] = Variable<String>(expectations.value);
    }
    if (decisionDate.present) {
      map['decision_date'] = Variable<DateTime>(decisionDate.value);
    }
    if (reviewDate.present) {
      map['review_date'] = Variable<DateTime>(reviewDate.value);
    }
    if (isReviewed.present) {
      map['is_reviewed'] = Variable<bool>(isReviewed.value);
    }
    if (reviewReflection.present) {
      map['review_reflection'] = Variable<String>(reviewReflection.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (reviewPeriodDays.present) {
      map['review_period_days'] = Variable<int>(reviewPeriodDays.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecisionEntriesCompanion(')
          ..write('decisionId: $decisionId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('options: $options, ')
          ..write('assumptions: $assumptions, ')
          ..write('expectations: $expectations, ')
          ..write('decisionDate: $decisionDate, ')
          ..write('reviewDate: $reviewDate, ')
          ..write('isReviewed: $isReviewed, ')
          ..write('reviewReflection: $reviewReflection, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('reviewPeriodDays: $reviewPeriodDays, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $LifeAuditsTable lifeAudits = $LifeAuditsTable(this);
  late final $WeeklyPulsesTable weeklyPulses = $WeeklyPulsesTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitLogsTable habitLogs = $HabitLogsTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $ThinkingCanvasSessionsTable thinkingCanvasSessions =
      $ThinkingCanvasSessionsTable(this);
  late final $ConsentLogsTable consentLogs = $ConsentLogsTable(this);
  late final $ReminderPreferencesTable reminderPreferences =
      $ReminderPreferencesTable(this);
  late final $WellnessPromptLogsTable wellnessPromptLogs =
      $WellnessPromptLogsTable(this);
  late final $DecisionEntriesTable decisionEntries = $DecisionEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    lifeAudits,
    weeklyPulses,
    habits,
    habitLogs,
    journalEntries,
    thinkingCanvasSessions,
    consentLogs,
    reminderPreferences,
    wellnessPromptLogs,
    decisionEntries,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String userId,
      required String ageBand,
      Value<String> supportMode,
      Value<String> engagementState,
      Value<String> timezone,
      Value<int> weekStartDay,
      Value<String?> latestDomainScores,
      Value<int> canopyLoadCapacity,
      Value<bool> wellnessDisclaimerAcknowledged,
      Value<DateTime?> lastWellnessPushAt,
      Value<DateTime?> lastWellnessPromptAt,
      Value<String> selectedSkin,
      Value<String> unlockedSkins,
      Value<String> securityLevel,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> themeMode,
      Value<String?> coreValues,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> userId,
      Value<String> ageBand,
      Value<String> supportMode,
      Value<String> engagementState,
      Value<String> timezone,
      Value<int> weekStartDay,
      Value<String?> latestDomainScores,
      Value<int> canopyLoadCapacity,
      Value<bool> wellnessDisclaimerAcknowledged,
      Value<DateTime?> lastWellnessPushAt,
      Value<DateTime?> lastWellnessPromptAt,
      Value<String> selectedSkin,
      Value<String> unlockedSkins,
      Value<String> securityLevel,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> themeMode,
      Value<String?> coreValues,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ageBand => $composableBuilder(
    column: $table.ageBand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supportMode => $composableBuilder(
    column: $table.supportMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engagementState => $composableBuilder(
    column: $table.engagementState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekStartDay => $composableBuilder(
    column: $table.weekStartDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestDomainScores => $composableBuilder(
    column: $table.latestDomainScores,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get canopyLoadCapacity => $composableBuilder(
    column: $table.canopyLoadCapacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wellnessDisclaimerAcknowledged => $composableBuilder(
    column: $table.wellnessDisclaimerAcknowledged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastWellnessPushAt => $composableBuilder(
    column: $table.lastWellnessPushAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastWellnessPromptAt => $composableBuilder(
    column: $table.lastWellnessPromptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedSkin => $composableBuilder(
    column: $table.selectedSkin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unlockedSkins => $composableBuilder(
    column: $table.unlockedSkins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get securityLevel => $composableBuilder(
    column: $table.securityLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coreValues => $composableBuilder(
    column: $table.coreValues,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ageBand => $composableBuilder(
    column: $table.ageBand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supportMode => $composableBuilder(
    column: $table.supportMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engagementState => $composableBuilder(
    column: $table.engagementState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekStartDay => $composableBuilder(
    column: $table.weekStartDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestDomainScores => $composableBuilder(
    column: $table.latestDomainScores,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get canopyLoadCapacity => $composableBuilder(
    column: $table.canopyLoadCapacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wellnessDisclaimerAcknowledged =>
      $composableBuilder(
        column: $table.wellnessDisclaimerAcknowledged,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get lastWellnessPushAt => $composableBuilder(
    column: $table.lastWellnessPushAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastWellnessPromptAt => $composableBuilder(
    column: $table.lastWellnessPromptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedSkin => $composableBuilder(
    column: $table.selectedSkin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unlockedSkins => $composableBuilder(
    column: $table.unlockedSkins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get securityLevel => $composableBuilder(
    column: $table.securityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coreValues => $composableBuilder(
    column: $table.coreValues,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get ageBand =>
      $composableBuilder(column: $table.ageBand, builder: (column) => column);

  GeneratedColumn<String> get supportMode => $composableBuilder(
    column: $table.supportMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get engagementState => $composableBuilder(
    column: $table.engagementState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get weekStartDay => $composableBuilder(
    column: $table.weekStartDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get latestDomainScores => $composableBuilder(
    column: $table.latestDomainScores,
    builder: (column) => column,
  );

  GeneratedColumn<int> get canopyLoadCapacity => $composableBuilder(
    column: $table.canopyLoadCapacity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wellnessDisclaimerAcknowledged =>
      $composableBuilder(
        column: $table.wellnessDisclaimerAcknowledged,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastWellnessPushAt => $composableBuilder(
    column: $table.lastWellnessPushAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastWellnessPromptAt => $composableBuilder(
    column: $table.lastWellnessPromptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedSkin => $composableBuilder(
    column: $table.selectedSkin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unlockedSkins => $composableBuilder(
    column: $table.unlockedSkins,
    builder: (column) => column,
  );

  GeneratedColumn<String> get securityLevel => $composableBuilder(
    column: $table.securityLevel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get coreValues => $composableBuilder(
    column: $table.coreValues,
    builder: (column) => column,
  );
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> ageBand = const Value.absent(),
                Value<String> supportMode = const Value.absent(),
                Value<String> engagementState = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> weekStartDay = const Value.absent(),
                Value<String?> latestDomainScores = const Value.absent(),
                Value<int> canopyLoadCapacity = const Value.absent(),
                Value<bool> wellnessDisclaimerAcknowledged =
                    const Value.absent(),
                Value<DateTime?> lastWellnessPushAt = const Value.absent(),
                Value<DateTime?> lastWellnessPromptAt = const Value.absent(),
                Value<String> selectedSkin = const Value.absent(),
                Value<String> unlockedSkins = const Value.absent(),
                Value<String> securityLevel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String?> coreValues = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                userId: userId,
                ageBand: ageBand,
                supportMode: supportMode,
                engagementState: engagementState,
                timezone: timezone,
                weekStartDay: weekStartDay,
                latestDomainScores: latestDomainScores,
                canopyLoadCapacity: canopyLoadCapacity,
                wellnessDisclaimerAcknowledged: wellnessDisclaimerAcknowledged,
                lastWellnessPushAt: lastWellnessPushAt,
                lastWellnessPromptAt: lastWellnessPromptAt,
                selectedSkin: selectedSkin,
                unlockedSkins: unlockedSkins,
                securityLevel: securityLevel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                themeMode: themeMode,
                coreValues: coreValues,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String ageBand,
                Value<String> supportMode = const Value.absent(),
                Value<String> engagementState = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> weekStartDay = const Value.absent(),
                Value<String?> latestDomainScores = const Value.absent(),
                Value<int> canopyLoadCapacity = const Value.absent(),
                Value<bool> wellnessDisclaimerAcknowledged =
                    const Value.absent(),
                Value<DateTime?> lastWellnessPushAt = const Value.absent(),
                Value<DateTime?> lastWellnessPromptAt = const Value.absent(),
                Value<String> selectedSkin = const Value.absent(),
                Value<String> unlockedSkins = const Value.absent(),
                Value<String> securityLevel = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String?> coreValues = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                userId: userId,
                ageBand: ageBand,
                supportMode: supportMode,
                engagementState: engagementState,
                timezone: timezone,
                weekStartDay: weekStartDay,
                latestDomainScores: latestDomainScores,
                canopyLoadCapacity: canopyLoadCapacity,
                wellnessDisclaimerAcknowledged: wellnessDisclaimerAcknowledged,
                lastWellnessPushAt: lastWellnessPushAt,
                lastWellnessPromptAt: lastWellnessPromptAt,
                selectedSkin: selectedSkin,
                unlockedSkins: unlockedSkins,
                securityLevel: securityLevel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                themeMode: themeMode,
                coreValues: coreValues,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$LifeAuditsTableCreateCompanionBuilder =
    LifeAuditsCompanion Function({
      required String auditId,
      required String userId,
      required String domainScores,
      required DateTime timestamp,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LifeAuditsTableUpdateCompanionBuilder =
    LifeAuditsCompanion Function({
      Value<String> auditId,
      Value<String> userId,
      Value<String> domainScores,
      Value<DateTime> timestamp,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$LifeAuditsTableFilterComposer
    extends Composer<_$AppDatabase, $LifeAuditsTable> {
  $$LifeAuditsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get auditId => $composableBuilder(
    column: $table.auditId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domainScores => $composableBuilder(
    column: $table.domainScores,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LifeAuditsTableOrderingComposer
    extends Composer<_$AppDatabase, $LifeAuditsTable> {
  $$LifeAuditsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get auditId => $composableBuilder(
    column: $table.auditId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domainScores => $composableBuilder(
    column: $table.domainScores,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LifeAuditsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LifeAuditsTable> {
  $$LifeAuditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get auditId =>
      $composableBuilder(column: $table.auditId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get domainScores => $composableBuilder(
    column: $table.domainScores,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LifeAuditsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LifeAuditsTable,
          LifeAudit,
          $$LifeAuditsTableFilterComposer,
          $$LifeAuditsTableOrderingComposer,
          $$LifeAuditsTableAnnotationComposer,
          $$LifeAuditsTableCreateCompanionBuilder,
          $$LifeAuditsTableUpdateCompanionBuilder,
          (
            LifeAudit,
            BaseReferences<_$AppDatabase, $LifeAuditsTable, LifeAudit>,
          ),
          LifeAudit,
          PrefetchHooks Function()
        > {
  $$LifeAuditsTableTableManager(_$AppDatabase db, $LifeAuditsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeAuditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LifeAuditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LifeAuditsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> auditId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> domainScores = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeAuditsCompanion(
                auditId: auditId,
                userId: userId,
                domainScores: domainScores,
                timestamp: timestamp,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String auditId,
                required String userId,
                required String domainScores,
                required DateTime timestamp,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeAuditsCompanion.insert(
                auditId: auditId,
                userId: userId,
                domainScores: domainScores,
                timestamp: timestamp,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LifeAuditsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LifeAuditsTable,
      LifeAudit,
      $$LifeAuditsTableFilterComposer,
      $$LifeAuditsTableOrderingComposer,
      $$LifeAuditsTableAnnotationComposer,
      $$LifeAuditsTableCreateCompanionBuilder,
      $$LifeAuditsTableUpdateCompanionBuilder,
      (LifeAudit, BaseReferences<_$AppDatabase, $LifeAuditsTable, LifeAudit>),
      LifeAudit,
      PrefetchHooks Function()
    >;
typedef $$WeeklyPulsesTableCreateCompanionBuilder =
    WeeklyPulsesCompanion Function({
      required String pulseId,
      required String userId,
      required String domainTag,
      required int score,
      Value<String?> reflectionText,
      required DateTime weekStartDate,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$WeeklyPulsesTableUpdateCompanionBuilder =
    WeeklyPulsesCompanion Function({
      Value<String> pulseId,
      Value<String> userId,
      Value<String> domainTag,
      Value<int> score,
      Value<String?> reflectionText,
      Value<DateTime> weekStartDate,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$WeeklyPulsesTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyPulsesTable> {
  $$WeeklyPulsesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pulseId => $composableBuilder(
    column: $table.pulseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domainTag => $composableBuilder(
    column: $table.domainTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reflectionText => $composableBuilder(
    column: $table.reflectionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeeklyPulsesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyPulsesTable> {
  $$WeeklyPulsesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pulseId => $composableBuilder(
    column: $table.pulseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domainTag => $composableBuilder(
    column: $table.domainTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflectionText => $composableBuilder(
    column: $table.reflectionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeeklyPulsesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyPulsesTable> {
  $$WeeklyPulsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pulseId =>
      $composableBuilder(column: $table.pulseId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get domainTag =>
      $composableBuilder(column: $table.domainTag, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get reflectionText => $composableBuilder(
    column: $table.reflectionText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$WeeklyPulsesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklyPulsesTable,
          WeeklyPulse,
          $$WeeklyPulsesTableFilterComposer,
          $$WeeklyPulsesTableOrderingComposer,
          $$WeeklyPulsesTableAnnotationComposer,
          $$WeeklyPulsesTableCreateCompanionBuilder,
          $$WeeklyPulsesTableUpdateCompanionBuilder,
          (
            WeeklyPulse,
            BaseReferences<_$AppDatabase, $WeeklyPulsesTable, WeeklyPulse>,
          ),
          WeeklyPulse,
          PrefetchHooks Function()
        > {
  $$WeeklyPulsesTableTableManager(_$AppDatabase db, $WeeklyPulsesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyPulsesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyPulsesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyPulsesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pulseId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> domainTag = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String?> reflectionText = const Value.absent(),
                Value<DateTime> weekStartDate = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeeklyPulsesCompanion(
                pulseId: pulseId,
                userId: userId,
                domainTag: domainTag,
                score: score,
                reflectionText: reflectionText,
                weekStartDate: weekStartDate,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pulseId,
                required String userId,
                required String domainTag,
                required int score,
                Value<String?> reflectionText = const Value.absent(),
                required DateTime weekStartDate,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeeklyPulsesCompanion.insert(
                pulseId: pulseId,
                userId: userId,
                domainTag: domainTag,
                score: score,
                reflectionText: reflectionText,
                weekStartDate: weekStartDate,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeeklyPulsesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklyPulsesTable,
      WeeklyPulse,
      $$WeeklyPulsesTableFilterComposer,
      $$WeeklyPulsesTableOrderingComposer,
      $$WeeklyPulsesTableAnnotationComposer,
      $$WeeklyPulsesTableCreateCompanionBuilder,
      $$WeeklyPulsesTableUpdateCompanionBuilder,
      (
        WeeklyPulse,
        BaseReferences<_$AppDatabase, $WeeklyPulsesTable, WeeklyPulse>,
      ),
      WeeklyPulse,
      PrefetchHooks Function()
    >;
typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      required String habitId,
      required String userId,
      Value<String?> domainTag,
      required String title,
      Value<String> status,
      Value<DateTime?> archivedAt,
      Value<String> frequency,
      Value<String?> scheduledDays,
      Value<int> initiationFriction,
      Value<int> originalFriction,
      Value<int> energyCost,
      Value<int> impactScore,
      Value<int> lifetimeDoneCount,
      Value<double> weightedDoneScore,
      Value<double?> completionRate90d,
      Value<DateTime?> lastDecayEvaluatedAt,
      Value<int> mvaDurationMin,
      Value<String?> stackedToHabitId,
      required DateTime createdAt,
      Value<DateTime?> deletedAt,
      Value<String?> goalTag,
      Value<int> rowid,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<String> habitId,
      Value<String> userId,
      Value<String?> domainTag,
      Value<String> title,
      Value<String> status,
      Value<DateTime?> archivedAt,
      Value<String> frequency,
      Value<String?> scheduledDays,
      Value<int> initiationFriction,
      Value<int> originalFriction,
      Value<int> energyCost,
      Value<int> impactScore,
      Value<int> lifetimeDoneCount,
      Value<double> weightedDoneScore,
      Value<double?> completionRate90d,
      Value<DateTime?> lastDecayEvaluatedAt,
      Value<int> mvaDurationMin,
      Value<String?> stackedToHabitId,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
      Value<String?> goalTag,
      Value<int> rowid,
    });

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domainTag => $composableBuilder(
    column: $table.domainTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initiationFriction => $composableBuilder(
    column: $table.initiationFriction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalFriction => $composableBuilder(
    column: $table.originalFriction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energyCost => $composableBuilder(
    column: $table.energyCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get impactScore => $composableBuilder(
    column: $table.impactScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lifetimeDoneCount => $composableBuilder(
    column: $table.lifetimeDoneCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightedDoneScore => $composableBuilder(
    column: $table.weightedDoneScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get completionRate90d => $composableBuilder(
    column: $table.completionRate90d,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastDecayEvaluatedAt => $composableBuilder(
    column: $table.lastDecayEvaluatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mvaDurationMin => $composableBuilder(
    column: $table.mvaDurationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stackedToHabitId => $composableBuilder(
    column: $table.stackedToHabitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalTag => $composableBuilder(
    column: $table.goalTag,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domainTag => $composableBuilder(
    column: $table.domainTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initiationFriction => $composableBuilder(
    column: $table.initiationFriction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalFriction => $composableBuilder(
    column: $table.originalFriction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energyCost => $composableBuilder(
    column: $table.energyCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get impactScore => $composableBuilder(
    column: $table.impactScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lifetimeDoneCount => $composableBuilder(
    column: $table.lifetimeDoneCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightedDoneScore => $composableBuilder(
    column: $table.weightedDoneScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get completionRate90d => $composableBuilder(
    column: $table.completionRate90d,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastDecayEvaluatedAt => $composableBuilder(
    column: $table.lastDecayEvaluatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mvaDurationMin => $composableBuilder(
    column: $table.mvaDurationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stackedToHabitId => $composableBuilder(
    column: $table.stackedToHabitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalTag => $composableBuilder(
    column: $table.goalTag,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get domainTag =>
      $composableBuilder(column: $table.domainTag, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initiationFriction => $composableBuilder(
    column: $table.initiationFriction,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalFriction => $composableBuilder(
    column: $table.originalFriction,
    builder: (column) => column,
  );

  GeneratedColumn<int> get energyCost => $composableBuilder(
    column: $table.energyCost,
    builder: (column) => column,
  );

  GeneratedColumn<int> get impactScore => $composableBuilder(
    column: $table.impactScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lifetimeDoneCount => $composableBuilder(
    column: $table.lifetimeDoneCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightedDoneScore => $composableBuilder(
    column: $table.weightedDoneScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get completionRate90d => $composableBuilder(
    column: $table.completionRate90d,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastDecayEvaluatedAt => $composableBuilder(
    column: $table.lastDecayEvaluatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mvaDurationMin => $composableBuilder(
    column: $table.mvaDurationMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stackedToHabitId => $composableBuilder(
    column: $table.stackedToHabitId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get goalTag =>
      $composableBuilder(column: $table.goalTag, builder: (column) => column);
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
          Habit,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> habitId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> domainTag = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String?> scheduledDays = const Value.absent(),
                Value<int> initiationFriction = const Value.absent(),
                Value<int> originalFriction = const Value.absent(),
                Value<int> energyCost = const Value.absent(),
                Value<int> impactScore = const Value.absent(),
                Value<int> lifetimeDoneCount = const Value.absent(),
                Value<double> weightedDoneScore = const Value.absent(),
                Value<double?> completionRate90d = const Value.absent(),
                Value<DateTime?> lastDecayEvaluatedAt = const Value.absent(),
                Value<int> mvaDurationMin = const Value.absent(),
                Value<String?> stackedToHabitId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> goalTag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion(
                habitId: habitId,
                userId: userId,
                domainTag: domainTag,
                title: title,
                status: status,
                archivedAt: archivedAt,
                frequency: frequency,
                scheduledDays: scheduledDays,
                initiationFriction: initiationFriction,
                originalFriction: originalFriction,
                energyCost: energyCost,
                impactScore: impactScore,
                lifetimeDoneCount: lifetimeDoneCount,
                weightedDoneScore: weightedDoneScore,
                completionRate90d: completionRate90d,
                lastDecayEvaluatedAt: lastDecayEvaluatedAt,
                mvaDurationMin: mvaDurationMin,
                stackedToHabitId: stackedToHabitId,
                createdAt: createdAt,
                deletedAt: deletedAt,
                goalTag: goalTag,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String habitId,
                required String userId,
                Value<String?> domainTag = const Value.absent(),
                required String title,
                Value<String> status = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String?> scheduledDays = const Value.absent(),
                Value<int> initiationFriction = const Value.absent(),
                Value<int> originalFriction = const Value.absent(),
                Value<int> energyCost = const Value.absent(),
                Value<int> impactScore = const Value.absent(),
                Value<int> lifetimeDoneCount = const Value.absent(),
                Value<double> weightedDoneScore = const Value.absent(),
                Value<double?> completionRate90d = const Value.absent(),
                Value<DateTime?> lastDecayEvaluatedAt = const Value.absent(),
                Value<int> mvaDurationMin = const Value.absent(),
                Value<String?> stackedToHabitId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> goalTag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion.insert(
                habitId: habitId,
                userId: userId,
                domainTag: domainTag,
                title: title,
                status: status,
                archivedAt: archivedAt,
                frequency: frequency,
                scheduledDays: scheduledDays,
                initiationFriction: initiationFriction,
                originalFriction: originalFriction,
                energyCost: energyCost,
                impactScore: impactScore,
                lifetimeDoneCount: lifetimeDoneCount,
                weightedDoneScore: weightedDoneScore,
                completionRate90d: completionRate90d,
                lastDecayEvaluatedAt: lastDecayEvaluatedAt,
                mvaDurationMin: mvaDurationMin,
                stackedToHabitId: stackedToHabitId,
                createdAt: createdAt,
                deletedAt: deletedAt,
                goalTag: goalTag,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
      Habit,
      PrefetchHooks Function()
    >;
typedef $$HabitLogsTableCreateCompanionBuilder =
    HabitLogsCompanion Function({
      required String logId,
      required String habitId,
      required DateTime date,
      required String status,
      Value<String?> frictionReasonSelected,
      Value<int?> durationTargetMin,
      Value<int?> durationActualMin,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$HabitLogsTableUpdateCompanionBuilder =
    HabitLogsCompanion Function({
      Value<String> logId,
      Value<String> habitId,
      Value<DateTime> date,
      Value<String> status,
      Value<String?> frictionReasonSelected,
      Value<int?> durationTargetMin,
      Value<int?> durationActualMin,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$HabitLogsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get logId => $composableBuilder(
    column: $table.logId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frictionReasonSelected => $composableBuilder(
    column: $table.frictionReasonSelected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationTargetMin => $composableBuilder(
    column: $table.durationTargetMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationActualMin => $composableBuilder(
    column: $table.durationActualMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get logId => $composableBuilder(
    column: $table.logId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frictionReasonSelected => $composableBuilder(
    column: $table.frictionReasonSelected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationTargetMin => $composableBuilder(
    column: $table.durationTargetMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationActualMin => $composableBuilder(
    column: $table.durationActualMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get logId =>
      $composableBuilder(column: $table.logId, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get frictionReasonSelected => $composableBuilder(
    column: $table.frictionReasonSelected,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationTargetMin => $composableBuilder(
    column: $table.durationTargetMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationActualMin => $composableBuilder(
    column: $table.durationActualMin,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$HabitLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitLogsTable,
          HabitLog,
          $$HabitLogsTableFilterComposer,
          $$HabitLogsTableOrderingComposer,
          $$HabitLogsTableAnnotationComposer,
          $$HabitLogsTableCreateCompanionBuilder,
          $$HabitLogsTableUpdateCompanionBuilder,
          (HabitLog, BaseReferences<_$AppDatabase, $HabitLogsTable, HabitLog>),
          HabitLog,
          PrefetchHooks Function()
        > {
  $$HabitLogsTableTableManager(_$AppDatabase db, $HabitLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> logId = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> frictionReasonSelected = const Value.absent(),
                Value<int?> durationTargetMin = const Value.absent(),
                Value<int?> durationActualMin = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitLogsCompanion(
                logId: logId,
                habitId: habitId,
                date: date,
                status: status,
                frictionReasonSelected: frictionReasonSelected,
                durationTargetMin: durationTargetMin,
                durationActualMin: durationActualMin,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String logId,
                required String habitId,
                required DateTime date,
                required String status,
                Value<String?> frictionReasonSelected = const Value.absent(),
                Value<int?> durationTargetMin = const Value.absent(),
                Value<int?> durationActualMin = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitLogsCompanion.insert(
                logId: logId,
                habitId: habitId,
                date: date,
                status: status,
                frictionReasonSelected: frictionReasonSelected,
                durationTargetMin: durationTargetMin,
                durationActualMin: durationActualMin,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitLogsTable,
      HabitLog,
      $$HabitLogsTableFilterComposer,
      $$HabitLogsTableOrderingComposer,
      $$HabitLogsTableAnnotationComposer,
      $$HabitLogsTableCreateCompanionBuilder,
      $$HabitLogsTableUpdateCompanionBuilder,
      (HabitLog, BaseReferences<_$AppDatabase, $HabitLogsTable, HabitLog>),
      HabitLog,
      PrefetchHooks Function()
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      required String entryId,
      required String userId,
      required DateTime date,
      required int moodScore,
      Value<String?> keyword,
      Value<String?> textContent,
      Value<String?> gratitudeText,
      Value<String> entryType,
      Value<String?> conflictCopy,
      Value<DateTime?> deletedAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> entryId,
      Value<String> userId,
      Value<DateTime> date,
      Value<int> moodScore,
      Value<String?> keyword,
      Value<String?> textContent,
      Value<String?> gratitudeText,
      Value<String> entryType,
      Value<String?> conflictCopy,
      Value<DateTime?> deletedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get moodScore => $composableBuilder(
    column: $table.moodScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gratitudeText => $composableBuilder(
    column: $table.gratitudeText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictCopy => $composableBuilder(
    column: $table.conflictCopy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get moodScore => $composableBuilder(
    column: $table.moodScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gratitudeText => $composableBuilder(
    column: $table.gratitudeText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictCopy => $composableBuilder(
    column: $table.conflictCopy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get moodScore =>
      $composableBuilder(column: $table.moodScore, builder: (column) => column);

  GeneratedColumn<String> get keyword =>
      $composableBuilder(column: $table.keyword, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gratitudeText => $composableBuilder(
    column: $table.gratitudeText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get conflictCopy => $composableBuilder(
    column: $table.conflictCopy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntry,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntry,
            BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
          ),
          JournalEntry,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entryId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> moodScore = const Value.absent(),
                Value<String?> keyword = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<String?> gratitudeText = const Value.absent(),
                Value<String> entryType = const Value.absent(),
                Value<String?> conflictCopy = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                entryId: entryId,
                userId: userId,
                date: date,
                moodScore: moodScore,
                keyword: keyword,
                textContent: textContent,
                gratitudeText: gratitudeText,
                entryType: entryType,
                conflictCopy: conflictCopy,
                deletedAt: deletedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entryId,
                required String userId,
                required DateTime date,
                required int moodScore,
                Value<String?> keyword = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<String?> gratitudeText = const Value.absent(),
                Value<String> entryType = const Value.absent(),
                Value<String?> conflictCopy = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                entryId: entryId,
                userId: userId,
                date: date,
                moodScore: moodScore,
                keyword: keyword,
                textContent: textContent,
                gratitudeText: gratitudeText,
                entryType: entryType,
                conflictCopy: conflictCopy,
                deletedAt: deletedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntry,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntry,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
      ),
      JournalEntry,
      PrefetchHooks Function()
    >;
typedef $$ThinkingCanvasSessionsTableCreateCompanionBuilder =
    ThinkingCanvasSessionsCompanion Function({
      required String sessionId,
      required String userId,
      required String methodKey,
      Value<String?> topic,
      Value<String?> rawNotes,
      Value<String?> summaryText,
      Value<bool> paperSession,
      Value<String?> paperArtifactRef,
      Value<String?> structuredOutput,
      Value<String?> nextAction,
      Value<String?> linkedHabitId,
      required DateTime createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ThinkingCanvasSessionsTableUpdateCompanionBuilder =
    ThinkingCanvasSessionsCompanion Function({
      Value<String> sessionId,
      Value<String> userId,
      Value<String> methodKey,
      Value<String?> topic,
      Value<String?> rawNotes,
      Value<String?> summaryText,
      Value<bool> paperSession,
      Value<String?> paperArtifactRef,
      Value<String?> structuredOutput,
      Value<String?> nextAction,
      Value<String?> linkedHabitId,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$ThinkingCanvasSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ThinkingCanvasSessionsTable> {
  $$ThinkingCanvasSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get methodKey => $composableBuilder(
    column: $table.methodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawNotes => $composableBuilder(
    column: $table.rawNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paperSession => $composableBuilder(
    column: $table.paperSession,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paperArtifactRef => $composableBuilder(
    column: $table.paperArtifactRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get structuredOutput => $composableBuilder(
    column: $table.structuredOutput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedHabitId => $composableBuilder(
    column: $table.linkedHabitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThinkingCanvasSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ThinkingCanvasSessionsTable> {
  $$ThinkingCanvasSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get methodKey => $composableBuilder(
    column: $table.methodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawNotes => $composableBuilder(
    column: $table.rawNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paperSession => $composableBuilder(
    column: $table.paperSession,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paperArtifactRef => $composableBuilder(
    column: $table.paperArtifactRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get structuredOutput => $composableBuilder(
    column: $table.structuredOutput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedHabitId => $composableBuilder(
    column: $table.linkedHabitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThinkingCanvasSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThinkingCanvasSessionsTable> {
  $$ThinkingCanvasSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get methodKey =>
      $composableBuilder(column: $table.methodKey, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get rawNotes =>
      $composableBuilder(column: $table.rawNotes, builder: (column) => column);

  GeneratedColumn<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get paperSession => $composableBuilder(
    column: $table.paperSession,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paperArtifactRef => $composableBuilder(
    column: $table.paperArtifactRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get structuredOutput => $composableBuilder(
    column: $table.structuredOutput,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedHabitId => $composableBuilder(
    column: $table.linkedHabitId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ThinkingCanvasSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThinkingCanvasSessionsTable,
          ThinkingCanvasSession,
          $$ThinkingCanvasSessionsTableFilterComposer,
          $$ThinkingCanvasSessionsTableOrderingComposer,
          $$ThinkingCanvasSessionsTableAnnotationComposer,
          $$ThinkingCanvasSessionsTableCreateCompanionBuilder,
          $$ThinkingCanvasSessionsTableUpdateCompanionBuilder,
          (
            ThinkingCanvasSession,
            BaseReferences<
              _$AppDatabase,
              $ThinkingCanvasSessionsTable,
              ThinkingCanvasSession
            >,
          ),
          ThinkingCanvasSession,
          PrefetchHooks Function()
        > {
  $$ThinkingCanvasSessionsTableTableManager(
    _$AppDatabase db,
    $ThinkingCanvasSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThinkingCanvasSessionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ThinkingCanvasSessionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ThinkingCanvasSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> methodKey = const Value.absent(),
                Value<String?> topic = const Value.absent(),
                Value<String?> rawNotes = const Value.absent(),
                Value<String?> summaryText = const Value.absent(),
                Value<bool> paperSession = const Value.absent(),
                Value<String?> paperArtifactRef = const Value.absent(),
                Value<String?> structuredOutput = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<String?> linkedHabitId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThinkingCanvasSessionsCompanion(
                sessionId: sessionId,
                userId: userId,
                methodKey: methodKey,
                topic: topic,
                rawNotes: rawNotes,
                summaryText: summaryText,
                paperSession: paperSession,
                paperArtifactRef: paperArtifactRef,
                structuredOutput: structuredOutput,
                nextAction: nextAction,
                linkedHabitId: linkedHabitId,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String userId,
                required String methodKey,
                Value<String?> topic = const Value.absent(),
                Value<String?> rawNotes = const Value.absent(),
                Value<String?> summaryText = const Value.absent(),
                Value<bool> paperSession = const Value.absent(),
                Value<String?> paperArtifactRef = const Value.absent(),
                Value<String?> structuredOutput = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<String?> linkedHabitId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThinkingCanvasSessionsCompanion.insert(
                sessionId: sessionId,
                userId: userId,
                methodKey: methodKey,
                topic: topic,
                rawNotes: rawNotes,
                summaryText: summaryText,
                paperSession: paperSession,
                paperArtifactRef: paperArtifactRef,
                structuredOutput: structuredOutput,
                nextAction: nextAction,
                linkedHabitId: linkedHabitId,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThinkingCanvasSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThinkingCanvasSessionsTable,
      ThinkingCanvasSession,
      $$ThinkingCanvasSessionsTableFilterComposer,
      $$ThinkingCanvasSessionsTableOrderingComposer,
      $$ThinkingCanvasSessionsTableAnnotationComposer,
      $$ThinkingCanvasSessionsTableCreateCompanionBuilder,
      $$ThinkingCanvasSessionsTableUpdateCompanionBuilder,
      (
        ThinkingCanvasSession,
        BaseReferences<
          _$AppDatabase,
          $ThinkingCanvasSessionsTable,
          ThinkingCanvasSession
        >,
      ),
      ThinkingCanvasSession,
      PrefetchHooks Function()
    >;
typedef $$ConsentLogsTableCreateCompanionBuilder =
    ConsentLogsCompanion Function({
      required String consentId,
      required String userId,
      required String consentType,
      required DateTime grantedAt,
      required String version,
      Value<DateTime?> revokedAt,
      Value<int> rowid,
    });
typedef $$ConsentLogsTableUpdateCompanionBuilder =
    ConsentLogsCompanion Function({
      Value<String> consentId,
      Value<String> userId,
      Value<String> consentType,
      Value<DateTime> grantedAt,
      Value<String> version,
      Value<DateTime?> revokedAt,
      Value<int> rowid,
    });

class $$ConsentLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ConsentLogsTable> {
  $$ConsentLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get consentId => $composableBuilder(
    column: $table.consentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consentType => $composableBuilder(
    column: $table.consentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get grantedAt => $composableBuilder(
    column: $table.grantedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConsentLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConsentLogsTable> {
  $$ConsentLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get consentId => $composableBuilder(
    column: $table.consentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consentType => $composableBuilder(
    column: $table.consentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get grantedAt => $composableBuilder(
    column: $table.grantedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConsentLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConsentLogsTable> {
  $$ConsentLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get consentId =>
      $composableBuilder(column: $table.consentId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get consentType => $composableBuilder(
    column: $table.consentType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get grantedAt =>
      $composableBuilder(column: $table.grantedAt, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);
}

class $$ConsentLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConsentLogsTable,
          ConsentLog,
          $$ConsentLogsTableFilterComposer,
          $$ConsentLogsTableOrderingComposer,
          $$ConsentLogsTableAnnotationComposer,
          $$ConsentLogsTableCreateCompanionBuilder,
          $$ConsentLogsTableUpdateCompanionBuilder,
          (
            ConsentLog,
            BaseReferences<_$AppDatabase, $ConsentLogsTable, ConsentLog>,
          ),
          ConsentLog,
          PrefetchHooks Function()
        > {
  $$ConsentLogsTableTableManager(_$AppDatabase db, $ConsentLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsentLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsentLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsentLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> consentId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> consentType = const Value.absent(),
                Value<DateTime> grantedAt = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsentLogsCompanion(
                consentId: consentId,
                userId: userId,
                consentType: consentType,
                grantedAt: grantedAt,
                version: version,
                revokedAt: revokedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String consentId,
                required String userId,
                required String consentType,
                required DateTime grantedAt,
                required String version,
                Value<DateTime?> revokedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsentLogsCompanion.insert(
                consentId: consentId,
                userId: userId,
                consentType: consentType,
                grantedAt: grantedAt,
                version: version,
                revokedAt: revokedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConsentLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConsentLogsTable,
      ConsentLog,
      $$ConsentLogsTableFilterComposer,
      $$ConsentLogsTableOrderingComposer,
      $$ConsentLogsTableAnnotationComposer,
      $$ConsentLogsTableCreateCompanionBuilder,
      $$ConsentLogsTableUpdateCompanionBuilder,
      (
        ConsentLog,
        BaseReferences<_$AppDatabase, $ConsentLogsTable, ConsentLog>,
      ),
      ConsentLog,
      PrefetchHooks Function()
    >;
typedef $$ReminderPreferencesTableCreateCompanionBuilder =
    ReminderPreferencesCompanion Function({
      required String habitId,
      Value<bool> reminderEnabled,
      Value<String> reminderTime,
      Value<String> quietHoursStart,
      Value<String> quietHoursEnd,
      Value<int> rowid,
    });
typedef $$ReminderPreferencesTableUpdateCompanionBuilder =
    ReminderPreferencesCompanion Function({
      Value<String> habitId,
      Value<bool> reminderEnabled,
      Value<String> reminderTime,
      Value<String> quietHoursStart,
      Value<String> quietHoursEnd,
      Value<int> rowid,
    });

class $$ReminderPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderPreferencesTable> {
  $$ReminderPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quietHoursStart => $composableBuilder(
    column: $table.quietHoursStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quietHoursEnd => $composableBuilder(
    column: $table.quietHoursEnd,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderPreferencesTable> {
  $$ReminderPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quietHoursStart => $composableBuilder(
    column: $table.quietHoursStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quietHoursEnd => $composableBuilder(
    column: $table.quietHoursEnd,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderPreferencesTable> {
  $$ReminderPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quietHoursStart => $composableBuilder(
    column: $table.quietHoursStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quietHoursEnd => $composableBuilder(
    column: $table.quietHoursEnd,
    builder: (column) => column,
  );
}

class $$ReminderPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderPreferencesTable,
          ReminderPreference,
          $$ReminderPreferencesTableFilterComposer,
          $$ReminderPreferencesTableOrderingComposer,
          $$ReminderPreferencesTableAnnotationComposer,
          $$ReminderPreferencesTableCreateCompanionBuilder,
          $$ReminderPreferencesTableUpdateCompanionBuilder,
          (
            ReminderPreference,
            BaseReferences<
              _$AppDatabase,
              $ReminderPreferencesTable,
              ReminderPreference
            >,
          ),
          ReminderPreference,
          PrefetchHooks Function()
        > {
  $$ReminderPreferencesTableTableManager(
    _$AppDatabase db,
    $ReminderPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderPreferencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReminderPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> habitId = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<String> reminderTime = const Value.absent(),
                Value<String> quietHoursStart = const Value.absent(),
                Value<String> quietHoursEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderPreferencesCompanion(
                habitId: habitId,
                reminderEnabled: reminderEnabled,
                reminderTime: reminderTime,
                quietHoursStart: quietHoursStart,
                quietHoursEnd: quietHoursEnd,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String habitId,
                Value<bool> reminderEnabled = const Value.absent(),
                Value<String> reminderTime = const Value.absent(),
                Value<String> quietHoursStart = const Value.absent(),
                Value<String> quietHoursEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderPreferencesCompanion.insert(
                habitId: habitId,
                reminderEnabled: reminderEnabled,
                reminderTime: reminderTime,
                quietHoursStart: quietHoursStart,
                quietHoursEnd: quietHoursEnd,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderPreferencesTable,
      ReminderPreference,
      $$ReminderPreferencesTableFilterComposer,
      $$ReminderPreferencesTableOrderingComposer,
      $$ReminderPreferencesTableAnnotationComposer,
      $$ReminderPreferencesTableCreateCompanionBuilder,
      $$ReminderPreferencesTableUpdateCompanionBuilder,
      (
        ReminderPreference,
        BaseReferences<
          _$AppDatabase,
          $ReminderPreferencesTable,
          ReminderPreference
        >,
      ),
      ReminderPreference,
      PrefetchHooks Function()
    >;
typedef $$WellnessPromptLogsTableCreateCompanionBuilder =
    WellnessPromptLogsCompanion Function({
      required String promptId,
      required String userId,
      required String triggerType,
      required DateTime promptedAt,
      Value<String?> userAction,
      Value<int> rowid,
    });
typedef $$WellnessPromptLogsTableUpdateCompanionBuilder =
    WellnessPromptLogsCompanion Function({
      Value<String> promptId,
      Value<String> userId,
      Value<String> triggerType,
      Value<DateTime> promptedAt,
      Value<String?> userAction,
      Value<int> rowid,
    });

class $$WellnessPromptLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WellnessPromptLogsTable> {
  $$WellnessPromptLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get promptId => $composableBuilder(
    column: $table.promptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get promptedAt => $composableBuilder(
    column: $table.promptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userAction => $composableBuilder(
    column: $table.userAction,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WellnessPromptLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WellnessPromptLogsTable> {
  $$WellnessPromptLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get promptId => $composableBuilder(
    column: $table.promptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get promptedAt => $composableBuilder(
    column: $table.promptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userAction => $composableBuilder(
    column: $table.userAction,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WellnessPromptLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WellnessPromptLogsTable> {
  $$WellnessPromptLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get promptedAt => $composableBuilder(
    column: $table.promptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userAction => $composableBuilder(
    column: $table.userAction,
    builder: (column) => column,
  );
}

class $$WellnessPromptLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WellnessPromptLogsTable,
          WellnessPromptLog,
          $$WellnessPromptLogsTableFilterComposer,
          $$WellnessPromptLogsTableOrderingComposer,
          $$WellnessPromptLogsTableAnnotationComposer,
          $$WellnessPromptLogsTableCreateCompanionBuilder,
          $$WellnessPromptLogsTableUpdateCompanionBuilder,
          (
            WellnessPromptLog,
            BaseReferences<
              _$AppDatabase,
              $WellnessPromptLogsTable,
              WellnessPromptLog
            >,
          ),
          WellnessPromptLog,
          PrefetchHooks Function()
        > {
  $$WellnessPromptLogsTableTableManager(
    _$AppDatabase db,
    $WellnessPromptLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WellnessPromptLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WellnessPromptLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WellnessPromptLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> promptId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> triggerType = const Value.absent(),
                Value<DateTime> promptedAt = const Value.absent(),
                Value<String?> userAction = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WellnessPromptLogsCompanion(
                promptId: promptId,
                userId: userId,
                triggerType: triggerType,
                promptedAt: promptedAt,
                userAction: userAction,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String promptId,
                required String userId,
                required String triggerType,
                required DateTime promptedAt,
                Value<String?> userAction = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WellnessPromptLogsCompanion.insert(
                promptId: promptId,
                userId: userId,
                triggerType: triggerType,
                promptedAt: promptedAt,
                userAction: userAction,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WellnessPromptLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WellnessPromptLogsTable,
      WellnessPromptLog,
      $$WellnessPromptLogsTableFilterComposer,
      $$WellnessPromptLogsTableOrderingComposer,
      $$WellnessPromptLogsTableAnnotationComposer,
      $$WellnessPromptLogsTableCreateCompanionBuilder,
      $$WellnessPromptLogsTableUpdateCompanionBuilder,
      (
        WellnessPromptLog,
        BaseReferences<
          _$AppDatabase,
          $WellnessPromptLogsTable,
          WellnessPromptLog
        >,
      ),
      WellnessPromptLog,
      PrefetchHooks Function()
    >;
typedef $$DecisionEntriesTableCreateCompanionBuilder =
    DecisionEntriesCompanion Function({
      required String decisionId,
      required String userId,
      required String title,
      required String description,
      required String options,
      required String assumptions,
      required String expectations,
      required DateTime decisionDate,
      required DateTime reviewDate,
      Value<bool> isReviewed,
      Value<String?> reviewReflection,
      Value<DateTime?> deletedAt,
      Value<int> reviewPeriodDays,
      Value<int> rowid,
    });
typedef $$DecisionEntriesTableUpdateCompanionBuilder =
    DecisionEntriesCompanion Function({
      Value<String> decisionId,
      Value<String> userId,
      Value<String> title,
      Value<String> description,
      Value<String> options,
      Value<String> assumptions,
      Value<String> expectations,
      Value<DateTime> decisionDate,
      Value<DateTime> reviewDate,
      Value<bool> isReviewed,
      Value<String?> reviewReflection,
      Value<DateTime?> deletedAt,
      Value<int> reviewPeriodDays,
      Value<int> rowid,
    });

class $$DecisionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DecisionEntriesTable> {
  $$DecisionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get decisionId => $composableBuilder(
    column: $table.decisionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assumptions => $composableBuilder(
    column: $table.assumptions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expectations => $composableBuilder(
    column: $table.expectations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get decisionDate => $composableBuilder(
    column: $table.decisionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewDate => $composableBuilder(
    column: $table.reviewDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewReflection => $composableBuilder(
    column: $table.reviewReflection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewPeriodDays => $composableBuilder(
    column: $table.reviewPeriodDays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DecisionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DecisionEntriesTable> {
  $$DecisionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get decisionId => $composableBuilder(
    column: $table.decisionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assumptions => $composableBuilder(
    column: $table.assumptions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expectations => $composableBuilder(
    column: $table.expectations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get decisionDate => $composableBuilder(
    column: $table.decisionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewDate => $composableBuilder(
    column: $table.reviewDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewReflection => $composableBuilder(
    column: $table.reviewReflection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewPeriodDays => $composableBuilder(
    column: $table.reviewPeriodDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DecisionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecisionEntriesTable> {
  $$DecisionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get decisionId => $composableBuilder(
    column: $table.decisionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<String> get assumptions => $composableBuilder(
    column: $table.assumptions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expectations => $composableBuilder(
    column: $table.expectations,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get decisionDate => $composableBuilder(
    column: $table.decisionDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewDate => $composableBuilder(
    column: $table.reviewDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewReflection => $composableBuilder(
    column: $table.reviewReflection,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get reviewPeriodDays => $composableBuilder(
    column: $table.reviewPeriodDays,
    builder: (column) => column,
  );
}

class $$DecisionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecisionEntriesTable,
          DecisionEntry,
          $$DecisionEntriesTableFilterComposer,
          $$DecisionEntriesTableOrderingComposer,
          $$DecisionEntriesTableAnnotationComposer,
          $$DecisionEntriesTableCreateCompanionBuilder,
          $$DecisionEntriesTableUpdateCompanionBuilder,
          (
            DecisionEntry,
            BaseReferences<_$AppDatabase, $DecisionEntriesTable, DecisionEntry>,
          ),
          DecisionEntry,
          PrefetchHooks Function()
        > {
  $$DecisionEntriesTableTableManager(
    _$AppDatabase db,
    $DecisionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecisionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecisionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecisionEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> decisionId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> options = const Value.absent(),
                Value<String> assumptions = const Value.absent(),
                Value<String> expectations = const Value.absent(),
                Value<DateTime> decisionDate = const Value.absent(),
                Value<DateTime> reviewDate = const Value.absent(),
                Value<bool> isReviewed = const Value.absent(),
                Value<String?> reviewReflection = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> reviewPeriodDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecisionEntriesCompanion(
                decisionId: decisionId,
                userId: userId,
                title: title,
                description: description,
                options: options,
                assumptions: assumptions,
                expectations: expectations,
                decisionDate: decisionDate,
                reviewDate: reviewDate,
                isReviewed: isReviewed,
                reviewReflection: reviewReflection,
                deletedAt: deletedAt,
                reviewPeriodDays: reviewPeriodDays,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String decisionId,
                required String userId,
                required String title,
                required String description,
                required String options,
                required String assumptions,
                required String expectations,
                required DateTime decisionDate,
                required DateTime reviewDate,
                Value<bool> isReviewed = const Value.absent(),
                Value<String?> reviewReflection = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> reviewPeriodDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecisionEntriesCompanion.insert(
                decisionId: decisionId,
                userId: userId,
                title: title,
                description: description,
                options: options,
                assumptions: assumptions,
                expectations: expectations,
                decisionDate: decisionDate,
                reviewDate: reviewDate,
                isReviewed: isReviewed,
                reviewReflection: reviewReflection,
                deletedAt: deletedAt,
                reviewPeriodDays: reviewPeriodDays,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DecisionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecisionEntriesTable,
      DecisionEntry,
      $$DecisionEntriesTableFilterComposer,
      $$DecisionEntriesTableOrderingComposer,
      $$DecisionEntriesTableAnnotationComposer,
      $$DecisionEntriesTableCreateCompanionBuilder,
      $$DecisionEntriesTableUpdateCompanionBuilder,
      (
        DecisionEntry,
        BaseReferences<_$AppDatabase, $DecisionEntriesTable, DecisionEntry>,
      ),
      DecisionEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$LifeAuditsTableTableManager get lifeAudits =>
      $$LifeAuditsTableTableManager(_db, _db.lifeAudits);
  $$WeeklyPulsesTableTableManager get weeklyPulses =>
      $$WeeklyPulsesTableTableManager(_db, _db.weeklyPulses);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitLogsTableTableManager get habitLogs =>
      $$HabitLogsTableTableManager(_db, _db.habitLogs);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$ThinkingCanvasSessionsTableTableManager get thinkingCanvasSessions =>
      $$ThinkingCanvasSessionsTableTableManager(
        _db,
        _db.thinkingCanvasSessions,
      );
  $$ConsentLogsTableTableManager get consentLogs =>
      $$ConsentLogsTableTableManager(_db, _db.consentLogs);
  $$ReminderPreferencesTableTableManager get reminderPreferences =>
      $$ReminderPreferencesTableTableManager(_db, _db.reminderPreferences);
  $$WellnessPromptLogsTableTableManager get wellnessPromptLogs =>
      $$WellnessPromptLogsTableTableManager(_db, _db.wellnessPromptLogs);
  $$DecisionEntriesTableTableManager get decisionEntries =>
      $$DecisionEntriesTableTableManager(_db, _db.decisionEntries);
}
