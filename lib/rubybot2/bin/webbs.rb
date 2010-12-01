#!/usr/bin/env ruby

# Ripped from http://www.dack.com/web/bullshit.html
VERBS = [
    'transform', 'embrace', 'enable', 'orchestrate', 'leverage', 'reinvent',
    'aggregate', 'architect', 'enhance', 'incentivize', 'morph', 'empower',
    'envisioneer', 'monetize', 'harness', 'facilitate', 'seize',
    'disintermediate', 'synergize', 'strategize', 'deploy', 'brand', 'grow',
    'target', 'syndicate', 'synthesize', 'deliver', 'mesh', 'incubate',
    'engage', 'maximize', 'benchmark', 'expedite', 'reintermediate',
    'whiteboard', 'visualize', 'repurpose', 'innovate', 'scale', 'unleash',
    'drive', 'extend', 'egineer', 'revolutionize', 'generate', 'exploit',
    'transition', 'e-enable', 'iterate', 'cultivate', 'matrix', 'productize',
    'redefine', 'recontextualize' ]
ADJECTIVES = [
    'clicks-and-mortar', 'value-added', 'vertical', 'proactive', 'robust',
    'revolutionary', 'scalable', 'leading-edge', 'innovative', 'intuitive',
    'strategic', 'e-business', 'mission-critical', 'sticky', 'one-to-one',
    '24/7', 'end-to-end', 'global', 'B2B', 'B2C', 'granular', 'frictionless',
    'virtual', 'viral', 'dynamic', '24/365', 'best-of-breed', 'killer',
    'magnetic', 'bleeding-edge', 'web-enabled', 'interactive', 'dot-com',
    'sexy', 'back-end', 'real-time', 'efficient', 'front-end', 'distributed',
    'seamless', 'extensible', 'turn-key', 'world-class', 'open-source',
    'cross-platform', 'cross-media', 'synergistic', 'bricks-and-clicks',
    'out-of-the-box', 'enterprise', 'integrated', 'impactful', 'wireless',
    'transparent', 'next-generation', 'cutting-edge', 'user-cetric',
    'visionary', 'customized', 'ubiquitous', 'plug-and-play', 'collaborative',
    'compelling', 'holistic' ]
NOUNS = [
    'synergies', 'web-readiness', 'paradigms', 'markets', 'partnerships',
    'infrastructures', 'platforms', 'initiatives', 'channels', 'eyeballs',
    'communities', 'ROI', 'solutions', 'e-tailers', 'e-services',
    'action-items', 'portals', 'niches', 'technologies', 'content', 'vortals',
    'supply-chains', 'convergence', 'relationships', 'architectures',
    'interfaces', 'e-markets', 'e-commerce', 'systems', 'bandwidth',
    'infomediaries', 'models', 'mindshare', 'deliverables', 'users', 'schemas',
    'networks', 'applicatons', 'metrics', 'e-business', 'functionalities',
    'experiences', 'web services', 'methodologies' ]

def r(ary)
    ary[rand(ary.length)]
end

def handle_command(nick, dest, args)
    "P\t.Com Bullshit: #{r(VERBS)} #{r(ADJECTIVES)} #{r(NOUNS)}"
end

load 'boilerplate.rb'
