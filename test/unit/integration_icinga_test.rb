# encoding: utf-8
require 'test_helper'

class IntegrationIcingaTest < ActiveSupport::TestCase

  test 'base tests' do

    Setting.set('ichinga_integration', true)

    # not matching sender
    email_raw_string = "To: support@example.com
Subject: PROBLEM - host.internal.loc - CPU Load is WARNING
User-Agent: Heirloom mailx 12.5 7/5/10
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Message-Id: <20160131094621.29ECD400F29C-1@monitoring.znuny.com>
From: icinga_not_matching@monitoring.example.com (icinga)

***** Icinga  *****

Notification Type: PROBLEM

Service: CPU Load
Host: host.internal.loc
Address:=20
State: WARNING

Date/Time: 2016-01-31 10:46:20 +0100

Additional Info: WARNING - load average: 3.44, 0.99, 0.35

Comment: [] =
"

    ticket_p, article_p, user_p, mail = Channel::EmailParser.new.process({}, email_raw_string)
    assert_equal('new', ticket_p.state.name)
    assert(ticket_p.preferences)
    assert_not(ticket_p.preferences['integration'])
    assert_not(ticket_p.preferences['ichinga'])

    # matching sender - CPU Load/host.internal.loc
    email_raw_string = "To: support@example.com
Subject: PROBLEM - host.internal.loc - CPU Load is WARNING
User-Agent: Heirloom mailx 12.5 7/5/10
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Message-Id: <20160131094621.29ECD400F29C-2@monitoring.znuny.com>
From: icinga@monitoring.example.com (icinga)

***** Icinga  *****

Notification Type: PROBLEM

Service: CPU Load
Host: host.internal.loc
Address:=20
State: WARNING

Date/Time: 2016-01-31 10:46:20 +0100

Additional Info: WARNING - load average: 3.44, 0.99, 0.35

Comment: [] =
"

    ticket_1, article_p, user_p, mail = Channel::EmailParser.new.process({}, email_raw_string)
    assert_equal('new', ticket_1.state.name)
    assert(ticket_1.preferences)
    assert(ticket_1.preferences['integration'])
    assert_equal('ichinga', ticket_1.preferences['integration'])
    assert(ticket_1.preferences['ichinga'])
    assert_equal('host.internal.loc', ticket_1.preferences['ichinga']['host'])
    assert_equal('CPU Load', ticket_1.preferences['ichinga']['service'])
    assert_equal('WARNING', ticket_1.preferences['ichinga']['state'])

    # matching sender - Disk Usage 123/host.internal.loc
    email_raw_string = "To: support@example.com
Subject: PROBLEM - host.internal.loc - Disk Usage 123 is WARNING
User-Agent: Heirloom mailx 12.5 7/5/10
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Message-Id: <20160131094621.29ECD400F29C-3@monitoring.znuny.com>
From: icinga@monitoring.example.com (icinga)

***** Icinga  *****

Notification Type: PROBLEM

Service: Disk Usage 123
Host: host.internal.loc
Address:=20
State: WARNING

Date/Time: 2016-01-31 10:46:20 +0100

Additional Info: WARNING - load average: 3.44, 0.99, 0.35

Comment: [] =
"

    ticket_2, article_p, user_p, mail = Channel::EmailParser.new.process({}, email_raw_string)
    assert_equal('new', ticket_2.state.name)
    assert(ticket_2.preferences)
    assert(ticket_2.preferences['integration'])
    assert_equal('ichinga', ticket_2.preferences['integration'])
    assert(ticket_2.preferences['ichinga'])
    assert_equal('host.internal.loc', ticket_2.preferences['ichinga']['host'])
    assert_equal('Disk Usage 123', ticket_2.preferences['ichinga']['service'])
    assert_equal('WARNING', ticket_2.preferences['ichinga']['state'])
    assert_not_equal(ticket_2.id, ticket_1.id)

    # matching sender - follow up - CPU Load/host.internal.loc
    email_raw_string = "To: support@example.com
Subject: PROBLEM - host.internal.loc - CPU Load is WARNING
User-Agent: Heirloom mailx 12.5 7/5/10
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Message-Id: <20160131094621.29ECD400F29C-4@monitoring.znuny.com>
From: icinga@monitoring.example.com (icinga)

***** Icinga  *****

Notification Type: PROBLEM

Service: CPU Load
Host: host.internal.loc
Address:=20
State: WARNING

Date/Time: 2016-01-31 10:46:20 +0100

Additional Info: WARNING - load average: 3.44, 0.99, 0.35

Comment: [] =
"

    ticket_1_1, article_p, user_p, mail = Channel::EmailParser.new.process({}, email_raw_string)
    assert_equal('new', ticket_1_1.state.name)
    assert(ticket_1_1.preferences)
    assert(ticket_1_1.preferences['integration'])
    assert_equal('ichinga', ticket_1_1.preferences['integration'])
    assert(ticket_1_1.preferences['ichinga'])
    assert_equal('host.internal.loc', ticket_1_1.preferences['ichinga']['host'])
    assert_equal('CPU Load', ticket_1_1.preferences['ichinga']['service'])
    assert_equal('WARNING', ticket_1_1.preferences['ichinga']['state'])
    assert_equal(ticket_1.id, ticket_1_1.id)

    # matching sender - follow up - recovery - CPU Load/host.internal.loc
    email_raw_string = "To: support@example.com
Subject: PROBLEM - host.internal.loc - CPU Load is WARNING
User-Agent: Heirloom mailx 12.5 7/5/10
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Message-Id: <20160131094621.29ECD400F29C-5@monitoring.znuny.com>
From: icinga@monitoring.example.com (icinga)

***** Icinga  *****

Notification Type: RECOVERY

Service: CPU Load
Host: host.internal.loc
Address:=20
State: OK

Date/Time: 2016-01-31 10:48:02 +0100

Additional Info: OK - load average: 1.62, 1.17, 0.49

Comment: [] =
"

    ticket_1_2, article_p, user_p, mail = Channel::EmailParser.new.process({}, email_raw_string)
    assert_equal(ticket_1.id, ticket_1_2.id)
    assert_equal('closed', ticket_1_2.state.name)
    assert(ticket_1_2.preferences)
    assert(ticket_1_2.preferences['integration'])
    assert_equal('ichinga', ticket_1_2.preferences['integration'])
    assert(ticket_1_2.preferences['ichinga'])
    assert_equal('host.internal.loc', ticket_1_2.preferences['ichinga']['host'])
    assert_equal('CPU Load', ticket_1_2.preferences['ichinga']['service'])
    assert_equal('WARNING', ticket_1_2.preferences['ichinga']['state'])

    #Setting.set('ichinga_integration', false)

  end

end
