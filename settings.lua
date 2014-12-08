vector = require "hump.vector"

return {
    coarse = {
        graphics = {
            tile_width = 64,
            background = {
                image = "data/background.png",
            },
            sprite = {
                tile = {
                    wall = {
                        default = "data/big/tiles/wall-1111.png",
                    },
                    ground = {
                        default = "data/big/tiles/ground.png",
                        target = "data/big/tiles/ground-target.png",
                    }
                },
                mob = {
                    crate = {
                        default = { 
                            default = { 
                                default = { 
                                    default = "data/big/mobs/crate.png",
                                    target = "data/big/mobs/crate-active.png",
                                },
                            },
                        },
                    },
                    character = {
                        default = {
                            up = "data/big/mobs/sigi-up.png",
                            left = "data/big/mobs/sigi-left.png",
                            down = "data/big/mobs/sigi-down.png",
                            right = "data/big/mobs/sigi-right.png",
                        },
                        moving = {
                            up = "data/big/mobs/sigi-up.png",
                            left = "data/big/mobs/sigi-left.png",
                            down = "data/big/mobs/sigi-down.png",
                            right = "data/big/mobs/sigi-right.png",
                        },
                    },
                },
            },
        },
        level = {
            image = "data/levels/coarse.png",
            character = { position = vector(2,2) },
        },
    },
    fine = {
        graphics = {
            tile_width = 4,
            sprite = {
                tile = {
                    wall = 0,
                    ground = {
                        default = "data/small/tiles/ground.png",
                        target = "data/small/tiles/target.png",
                    },
                },
                mob = {
                    crate = {
						default = { 
                            default = { 
                                default = { 
									default = "data/small/mobs/crate.png",
									target = "data/small/mobs/crate-active.png",
								},
							},
						},
					},
                    character = "data/small/mobs/character.png",
                },
            },
        },
        level = {
            image = "data/levels/fine.png",
            character = { position = vector(15,34) },
        },
    },
    crates = {
        level = {
            image = "data/levels/crates.png",
        },
    },
    
    control = { -- see <http://www.love2d.org/wiki/KeyConstant> for the name of various keys
        key = {
            ['w'] = 'coarse.up',
            ['a'] = 'coarse.left',
            ['s'] = 'coarse.down',
            ['d'] = 'coarse.right',
            ['i'] = 'fine.up',
            ['j'] = 'fine.left',
            ['k'] = 'fine.down',
            ['l'] = 'fine.right',
        },
    },
}
