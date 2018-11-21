local lib = {
  manifestIni(ini)::
    local body_lines(body) =
      std.join([], [
        local value_or_values = body[k];
        if std.type(value_or_values) == 'array' then
          ['%s = %s' % [k, value] for value in value_or_values]
        else
          ['%s = %s' % [k, value_or_values]]

        for k in std.objectFields(body)
      ]);

    local section_lines(sname, sbody) = ['[%s]' % [sname]] + body_lines(sbody),
          main_body = if std.objectHas(ini, 'main') then body_lines(ini.main) else [],
          all_sections = [
      section_lines(k, ini.sections[k])
      for k in std.objectFields(ini.sections)
    ];
    std.join('\n', main_body + std.flattenArrays(all_sections) + ['']),
};

local backup = 'backup2';
local node = 'localhost';
local vol = 'root';

local when = 'everyday at 00:20';
local nicelevel = 19;
local testconnect = 'no';

local base = '/space/duplicity';
local tmpdir = base + '/tmp';
local archive = base + '/archive';
local volsize = 500;

local name = backup + '+' + node + '+' + vol;
local onefs = ' --exclude-other-filesystems';

local options = '--archive-dir ' + archive + ' --name ' + name + ' --volsize ' + volsize + onefs;

local conf = {
  main: {
    when: when,
    nicelevel: nicelevel,
    testconnect: testconnect,
    tmpdir: tmpdir,
    options: options,
  },
  sections: {
    gpg: {
      encryptkey: 't.delamare@epiconcept.fr'
    },
    source: {
      include: [
	'/*', /**/
	],
      exclude: '/space',
    },
    dest: {
      incremental: 'yes',
      increments: 7,
      keep: 60,
      keepincroffulls: 4,
      sshoptions: '-oIdentityFile=/etc/duplicity/' + node + '-duplicity',
      desthost: 'backup2.admin2.oxa.tld',
      destuser: 'duplicity',
      destdir: 'store/' + node + '/' + vol
    },
  },
};

std.manifestIni(conf)
