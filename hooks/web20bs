#!/usr/bin/env ruby

# Ripped from http://emptybottle.org/bullshit/
VERBS = [
    'aggregate', 'beta-test', 'integrate', 'capture', 'create', 'design',
    'disintermediate', 'enable', 'integrate', 'post', 'remix', 'reinvent',
    'share', 'syndicate', 'tag', 'incentivize', 'engage', 'reinvent',
    'harness', 'integrate',
    # mine
    'podcast', 'vidcast', 'ajaxify', 'blogify']
ADJECTIVES = [
    'AJAX-enabled', 'A-list', 'authentic','citizen-media', 'Cluetrain',
    'data-driven', 'dynamic', 'embedded', 'long-tail', 'peer-to-peer',
    'podcasting', 'rss-capable', 'semantic', 'social', 'standards-compliant',
    'user-centred', 'user-contributed', 'viral', 'blogging', 'rich-client']
NOUNS = [
    'APIs', 'blogospheres', 'communities', 'ecologies', 'feeds', 'folksonomies',
    'life-hacks', 'mashups', 'network effects', 'networking', 'platforms',
    'podcasts', 'value', 'web services', 'weblogs', 'widgets', 'wikis',
    'synergies',
    # mine
    'service-oriented architectures', 'tag cloud']

def r(ary)
    ary[rand(ary.length)]
end

def handle_command(nick, dest, args)
    "P\tWeb 2.0 Bullshit: #{r(VERBS)} #{r(ADJECTIVES)} #{r(NOUNS)}"
end

load 'boilerplate.rb'
